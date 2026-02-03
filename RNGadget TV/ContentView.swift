//
//  ContentView.swift
//  RNGTool TV
//
//  Created by Campbell on 7/18/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settingsData: SettingsData
    
    var body: some View {
        NavigationStack {
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
                    NavigationLink(destination: History()) {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.accentColor)
                        Text("History")
                    }
                }
            }
            .navigationTitle("RNGTool")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            Text("Select a mode to start generating")
        }
    }
}

#Preview {
    ContentView()
}
