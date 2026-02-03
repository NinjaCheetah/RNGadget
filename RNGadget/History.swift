//
//  History.swift
//  RNGTool
//
//  Created by Campbell on 12/25/21.
//

import SwiftUI
import Foundation

struct History: View {
    @EnvironmentObject var settingsData: SettingsData
    @State private var selectedEntries = Set<HistoryTable.ID>()
    @State private var confirmReset: Bool = false
    
    func clearHistory() {
        settingsData.historyTable.removeAll()
        confirmReset = false
    }
    
    var body: some View {
        // History on macOS, now with 100% more actual table! This looks much much better.
        Table(settingsData.historyTable, selection: $selectedEntries) {
            TableColumn("Mode Used") { item in
                Text(item.modeUsed)
                    .contextMenu {
                        Button("Copy") {
                            copyToClipboard(item: item.modeUsed)
                        }
                    }
            }
            TableColumn("Result(s)") { item in
                Text(item.numbers)
                    .contextMenu {
                        Button("Copy") {
                            copyToClipboard(item: item.numbers)
                        }
                    }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    confirmReset = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .alert("Clear History", isPresented: $confirmReset, actions: {
            Button("Confirm", role: .destructive) {
                clearHistory()
            }
        }, message: {
            Text("Are you sure you want to clear your RNGTool history?")
        })
    }
}

#Preview {
    History().environmentObject(SettingsData())
}
