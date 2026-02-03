//
//  ContentView.swift
//  RNGToolWrist
//
//  Created by Campbell on 2/15/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settingsData: SettingsData
    #if DEBUG
    @State private var dbgKBValue: Int = 13
    @State private var dbgShowKB: Bool = false
    #endif
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Modes")) {
                    NavigationLink(destination: NumberMode()) {
                        Image(systemName: "number")
                            .foregroundColor(.accentColor)
                        Text("Numbers")
                    }
                    NavigationLink(destination: CoinMode()) {
                        Image(systemName: "centsign.circle")
                            .foregroundColor(.accentColor)
                        Text("Coins")
                    }
                    NavigationLink(destination: DiceMode()) {
                        Image(systemName: "dice")
                            .foregroundColor(.accentColor)
                        Text("Dice")
                    }
                    NavigationLink(destination: CardMode()) {
                        Image(systemName: "rectangle.grid.3x2")
                            .foregroundColor(.accentColor)
                        Text("Cards")
                    }
                    NavigationLink(destination: MarbleMode()) {
                        Image(systemName: "a.circle")
                            .foregroundColor(.accentColor)
                        Text("Marbles")
                    }
                }
                Section(header: Text("More")) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                            .foregroundColor(.accentColor)
                        Text("Settings")
                    }
                    #if DEBUG
                    if settingsData.showDevMode {
                        Button(action: {
                            dbgShowKB = true
                        }) {
                            HStack() {
                                Image(systemName: "keyboard")
                                    .foregroundColor(.accentColor)
                                Text("KB Debug")
                            }
                        }
                        .sheet(isPresented: $dbgShowKB) {
                            NumKeyboard(targetNumber: $dbgKBValue)
                                .toolbar(content: {
                                    ToolbarItem(placement: .cancellationAction) {
                                        Button("Cancel") { dbgShowKB = false }
                                    }
                                    ToolbarItem(placement: .confirmationAction) {
                                        Button("Done") { dbgShowKB = false }
                                    }
                                })
                        }
                    }
                    #endif
                }
            }
            .navigationTitle("RNGTool")
            Text("Select a mode to start generating")
        }
    }
}

#Preview {
    ContentView()
}
