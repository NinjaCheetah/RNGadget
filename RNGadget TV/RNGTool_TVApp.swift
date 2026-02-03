//
//  RNGTool_TVApp.swift
//  RNGTool TV
//
//  Created by Campbell on 7/18/25.
//

import SwiftUI

@main
struct RNGTool_TVApp: App {
    @StateObject var settingsData: SettingsData = SettingsData()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(settingsData)
        }
    }
}
