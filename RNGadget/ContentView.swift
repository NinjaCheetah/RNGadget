//
//  ContentView.swift
//  RNGTool
//
//  Created by Campbell on 8/30/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settingsData: SettingsData
    let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    let buildNumberStr: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    
    // Legacy function to toggle the sidebar, because it seems that the SwiftUI-native way requires macOS 13.0+.
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
    
    var body: some View {
        NavigationView {
            List() {
                Section(header: Text("Basic Modes")) {
                    NavigationLink(destination: NumberMode()) {
                        Label("Numbers", systemImage: "number")
                            .tint(.accentColor)
                    }
                    NavigationLink(destination: CoinMode()) {
                        Label("Coins", systemImage: "centsign.circle")
                            .tint(.accentColor)
                    }
                    NavigationLink(destination: DiceMode()) {
                        Label("Dice", systemImage: "dice")
                            .tint(.accentColor)
                    }
                    NavigationLink(destination: CardMode()) {
                        Label("Cards", systemImage: "rectangle.grid.3x2")
                            .tint(.accentColor)
                    }
                    NavigationLink(destination: MarbleMode()) {
                        Label("Marbles", systemImage: "a.circle")
                            .tint(.accentColor)
                    }
                }
                Section(header: Text("Advanced Modes")) {
                    NavigationLink(destination: DealerMode()) {
                        Label("Dealer", systemImage: "hand.wave")
                            .tint(.accentColor)
                    }
                }
                Section(header: Text("More")) {
                    NavigationLink(destination: History()) {
                        Label("History", systemImage: "clock.arrow.circlepath")
                    }
                }
            }
            Text("Select a mode to start generating")
        }
        .navigationTitle("RNGadget")
        .frame(minWidth: 700, minHeight: 300) // Minimum size for the area that the selected mode occupies
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.leading")
                })
            }
        }
        .onAppear {
            if (settingsData.checkUpdatesOnStartup) {
                checkForUpdates { result in
                    DispatchQueue.global().async {
                        switch result {
                            case .success(let value):
                                print("API access complete!")
                                let tagName: String = value.tagName
                                DispatchQueue.main.sync {
                                    if(compareVersions(remoteVersion: tagName)) {
                                        OpenWindows.Update.open()
                                    }
                                }
                            case .failure(let error): print(error)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
