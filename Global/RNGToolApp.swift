//
//  RNGToolApp.swift
//  RNGTool
//
//  Created by Campbell on 8/30/21.
//

import SwiftUI

@main
struct RNGToolApp: App {
    @StateObject var settingsData: SettingsData = SettingsData()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(settingsData)
        }
        #if !os(watchOS)
        .commands {
            RNGToolCommands()
        }
        #endif
        #if os(macOS)
        Settings {
            SettingsView().environmentObject(settingsData)
        }
        WindowGroup("Update") {
            UpdateCheck()
                .frame(width: 300, height: 100)
                .frame(maxWidth: 300, maxHeight: 100)
        }.handlesExternalEvents(matching: Set(arrayLiteral: "Update"))
        #endif
    }
}

#if os(macOS)
enum OpenWindows: String, CaseIterable {
    case Update = "Update"

    func open(){
        if let url = URL(string: "rngadget://\(self.rawValue)") {
            NSWorkspace.shared.open(url)
        }
    }
}
#endif
