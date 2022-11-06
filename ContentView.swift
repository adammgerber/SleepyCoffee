//
//  ContentView.swift
//  BetterRest
//
//  Created by Adam Gerber on 06/11/2022.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    // we can make defaultWakeTime a static variable, which means it belongs to the ContentView struct itself rather than a single instance of that struct
    
    //This in turn means defaultWakeTime can be read whenever we want, because it doesn’t rely on the existence of any other properties
    
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    func calculatedBedtime(){
        do{
            let config = MLModelConfiguration()
            let model = try Sleepcalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch{
            //something went wrong
        }
        
        showingAlert = true
    }
    
    var body: some View {
        NavigationView{
            Form{
                Section{
                    
                    DatePicker("Please pick a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                } header: {
                    Text("When do you want to wake up?")
                }
                Section{
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                } header : {
                    Text("Desired amount of sleep")
                }
                Section{
                    Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                } header: {
                    Text("Daily coffee intake")
                }
            }
            .navigationTitle("SleepyCoffee")
            .toolbar {
                Button("Calculate", action: calculatedBedtime)
            }
            .alert(alertTitle, isPresented: $showingAlert){
                Button("OK"){}
            } message: {
                    Text(alertMessage)
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
