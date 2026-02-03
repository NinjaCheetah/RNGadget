//
//  DevMode.swift
//  RNGTool Mobile
//
//  Created by Campbell on 1/8/22.
//

import SwiftUI

// This view just exists to provide easy access to some features that are handy for testing. The name makes it sound wayyyyy cooler.
struct DevMode: View {
    @EnvironmentObject var settingsData: SettingsData
    @SceneStorage("NumberMode.randomNumber") private var numRandomNumber = 0
    @SceneStorage("CoinMode.coinCount") private var coinCoinCount = 0
    @SceneStorage("CoinMode.headsCount") private var coinHeadsCount = 0
    @SceneStorage("CoinMode.tailsCount") private var coinTailsCount = 0
    @State private var historyModeInput = ""
    @State private var historyNumberInput = ""
    
    var body: some View {
        Form {
            Section(header: Text("History Table Manipulation"), footer: Text("This will append a new entry with the specified values to the number history table. This does not check for a maximum before appending.")) {
                Text("Mode Used")
                TextField(text: $historyModeInput, prompt: Text("Required")) {
                    Text("Mode Used")
                }
                Text("Numbers")
                TextField(text: $historyNumberInput, prompt: Text("Required")) {
                    Text("Result")
                }
                Button(action:{
                    addHistoryEntry(settingsData: settingsData, results: historyNumberInput, mode: historyModeInput)
                }) {
                    Text("Append")
                }
            }
            Section(footer: Text("This will add 5 sample card mode results to the history table.")) {
                Button(action: {
                    addHistoryEntry(settingsData: settingsData, results: "6♣️, Q♣️, 2♦️, 8♥️, 7♠️, 4♣️, K♥️", mode: "Card Mode")
                    addHistoryEntry(settingsData: settingsData, results: "10♦️, 5♥️, 4♥️, K♣️, J♦️, J♠️, 2♠️", mode: "Card Mode")
                    addHistoryEntry(settingsData: settingsData, results: "10♣️, 2♦️, K♦️, Q♠️, 9♣️, 8♠️, 2♠️", mode: "Card Mode")
                    addHistoryEntry(settingsData: settingsData, results: "5♥️, 5♦️, 10♣️, 10♠️, 5♠️, 4♦️, 6♦️", mode: "Card Mode")
                    addHistoryEntry(settingsData: settingsData, results: "3♣️, 8♦️, K♣️, Q♣️, 2♦️, A♦️, K♥️", mode: "Card Mode")
                }) {
                    Text("Card Spam")
                }
            }
            Section(footer: Text("This will erase all entries in the table.")) {
                Text("Entries: \(settingsData.historyTable.count)")
                Button(action:{
                    settingsData.historyTable.removeAll()
                }) {
                    Text("Reset Table")
                }
            }
            Section(header: Text("@SceneStorage Manipulation"), footer: Text("Edit the values stored in @SceneStorage for number mode.")) {
                HStack() {
                    Image(systemName: "number")
                        .foregroundColor(.accentColor)
                    Text("randomNumber")
                }
                TextField("Enter a number", value: $numRandomNumber, format: .number)
                    .keyboardType(.numberPad)
            }
            Section(footer: Text("Edit the values stored in @SceneStorage for coin mode.")) {
                HStack() {
                    Image(systemName: "centsign.circle")
                        .foregroundColor(.accentColor)
                    Text("coinCount")
                }
                TextField("Enter a number", value: $coinCoinCount, format: .number)
                .keyboardType(.numberPad)
                HStack() {
                    Image(systemName: "centsign.circle")
                        .foregroundColor(.accentColor)
                    Text("headsCount")
                }
                TextField("Enter a number", value: $coinHeadsCount, format: .number)
                .keyboardType(.numberPad)
                HStack() {
                    Image(systemName: "centsign.circle")
                        .foregroundColor(.accentColor)
                    Text("tailsCount")
                }
                TextField("Enter a number", value: $coinTailsCount, format: .number)
                .keyboardType(.numberPad)
            }
        }
        .padding(.horizontal, 3)
        .navigationTitle("Developer Mode")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DevMode_Previews: PreviewProvider {
    static var previews: some View {
        DevMode().environmentObject(SettingsData())
    }
}
