//
//  ContentView.swift
//  RNGTool Mobile
//
//  Created by Campbell on 12/14/21.
//

import SwiftUI
import UIKit

// This extension makes it so that navigationViewStyle is only set to the default (.automatic) on iPad, and on iPhone (or god forbid, iPod
// Touch) it'll use the stack style. Using stack over automatic makes no visible difference on iPhone, but it fixes a navigation issue with
// the Advanced Settings.
extension View {
    @ViewBuilder func phoneOnlyStackNavigationView() -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.navigationViewStyle(.automatic)
        } else {
            self.navigationViewStyle(.stack)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var settingsData: SettingsData
    
    var body: some View {
        NavigationView {
            Form {
                // All of RNGTool's basic modes.
                Section(header: Text("Basic Modes")) {
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
                // All of RNGTool's advanced modes.
                Section(header: Text("Advanded Modes")) {
                    if settingsData.showDevMode {
                        NavigationLink(destination: AdvCardMode()) {
                            Image(systemName: "rectangle.grid.3x2")
                                .foregroundColor(.accentColor)
                            Text("Cards+")
                        }
                    }
                    NavigationLink(destination: DealerMode()) {
                        Image(systemName: "hand.wave")
                            .foregroundColor(.accentColor)
                        Text("Dealer")
                    }
                    if settingsData.showDevMode {
                        NavigationLink(destination: RPGDiceMode()) {
                            Image(systemName: "shield.lefthalf.filled")
                                .foregroundColor(.accentColor)
                            Text("RPG Dice")
                        }
                        NavigationLink(destination: ThresholdDiceMode()) {
                            Image(systemName: "arrow.up.to.line")
                                .foregroundColor(.accentColor)
                            Text("Threshold Dice")
                        }
                    }
                }
                // Other stuff, basically just history and dev mode.
                Section(header: Text("More")) {
                    NavigationLink(destination: History()) {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.accentColor)
                        Text("History")
                    }
                    if settingsData.showDevMode {
                        NavigationLink(destination: DevMode()) {
                            Image(systemName: "hammer")
                                .foregroundColor(.accentColor)
                            Text("Developer Mode")
                        }
                    }
                }
            }
            .navigationTitle("RNGadget")
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
        .phoneOnlyStackNavigationView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView().environmentObject(SettingsData())
        }
    }
}
