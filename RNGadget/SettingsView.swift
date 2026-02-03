//
//  SettingsView.swift
//  RNGTool
//
//  Created by Campbell on 9/22/21.
//

import SwiftUI

struct SettingsView: View {
    private enum Tabs: Hashable {
            case general, number, card, advanced
    }
    var body: some View {
        TabView {
            Form {
                GeneralSettings()
            }
            .tabItem {
                Label("General", systemImage: "gear")
            }
            .tag(Tabs.general)
            NumberSettings()
                .tabItem {
                    Label("Number Mode", systemImage: "number")
                }
                .tag(Tabs.number)
            Form {
                CardSettings()
            }
            .tabItem {
                Label("Card Mode", systemImage: "rectangle.grid.3x2")
            }
            .tag(Tabs.card)
            Form {
                AdvancedSettings()
            }
            .tabItem {
                Label("Advanced", systemImage: "gearshape.2")
            }
            .tag(Tabs.advanced)
        }
        .padding(20)
        .frame(width: 600, height: 250)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
