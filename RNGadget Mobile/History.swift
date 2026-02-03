//
//  History.swift
//  RNGTool Mobile
//
//  Created by Campbell on 1/7/22.
//

import SwiftUI

// View to handle each row in the history table, because the compiler didn't like it when this was inlined.
struct HistoryRow: View {
    var modeUsed: String
    var result: String
    var index: Int
    
    // The contraints in here are my personal hell but it makes a really nice pseudo-table so I guess they're here to stay.
    // Seriously though it kills me that I need to recreate the look of a table from scratch here, because tables in SwiftUI will only
    // ever show the first column on iOS. What's even the point of a table if it can't have headers and can only show one column??
    var body: some View {
        HStack(alignment: .center) {
            HStack() {
                VStack {
                    Text(modeUsed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                VStack {
                    Text(result)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.all, 6)
        }
        .background (
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(index % 2 == 0 ? 0.0 : 0.3))
        )
    }
}

struct History: View {
    @EnvironmentObject var settingsData: SettingsData
    @State private var confirmReset: Bool = false
    
    func clearHistory() {
        settingsData.historyTable.removeAll()
        confirmReset = false
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    VStack {
                        Text("Mode Used")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.secondary)
                        Divider()
                    }
                    VStack {
                        Text("Result(s)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.secondary)
                        Divider()
                    }
                }
                .padding(.horizontal, 3)
                if(settingsData.historyTable.count == 0) {
                    Text("No history yet! Get generating!")
                        .padding(.top, 10)
                }
                // Actual entries are shown here
                ForEach(0..<settingsData.historyTable.count, id: \.self) { index in
                    HistoryRow(modeUsed: settingsData.historyTable[index].modeUsed,
                               result: settingsData.historyTable[index].numbers,
                               index: index)
                }
            }
        }
        .padding(.horizontal, 6)
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
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

struct History_Previews: PreviewProvider {
    static var previews: some View {
        History().environmentObject(SettingsData())
    }
}
