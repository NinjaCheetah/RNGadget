//
//  History.swift
//  RNGTool TV
//
//  Created by Campbell on 7/19/25.
//

import SwiftUI

struct History: View {
    @EnvironmentObject var settingsData: SettingsData
    @State private var confirmReset: Bool = false
    
    func clearHistory() {
        settingsData.historyTable.removeAll()
        confirmReset = false
    }
    
    var body: some View {
        ScrollView {
            HStack {
                VStack {
                    Text("Mode Used")
                        .foregroundColor(.secondary)
                    Divider()
                    ForEach(0..<settingsData.historyTable.count, id: \.self) { index in
                        Text("\(settingsData.historyTable[index].modeUsed)")
                            .padding(.bottom, 3)
                    }
                    Spacer()
                }
                VStack {
                    Text("Result(s)")
                        .foregroundColor(.secondary)
                    Divider()
                    ForEach(0..<settingsData.historyTable.count, id: \.self) { index in
                        Text("\(settingsData.historyTable[index].numbers)")
                            .padding(.bottom, 3)
                    }
                    Spacer()
                }
            }
            if(settingsData.historyTable.count == 0) {
                Text("No history yet! Get generating!")
            }
        }
        .padding(.horizontal, 3)
        .navigationTitle("History")
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
