//
//  DiceMode.swift
//  RNGTool TV
//
//  Created by Campbell on 7/19/25.
//

import SwiftUI

struct DiceMode: View {
    @EnvironmentObject var settingsData: SettingsData
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var numDice: Int = 1
    @State private var confirmReset: Bool = false
    @State private var showingExplainer: Bool = false
    @State private var randomNumbers: [Int] = [0]
    @State private var diceImages: [String] = Array(repeating: "d1", count: 18)
    @State private var rollCount: Int = 0
    @State private var rollTask: Task<Void, Never>? = nil
    
    func resetGen() {
        rollTask?.cancel()
        rollTask = nil
        numDice = 1
        diceImages = Array(repeating: "d1", count: 18)
        confirmReset = false
    }
    
    // Roll function that generates a number for every die being shown in the range 1-6, and then sets each shown die to the image that
    // corresponds with the number rolled for it.
    func roll() {
        randomNumbers = (1...numDice).map { _ in Int.random(in: 1...6) }
        for n in 0..<randomNumbers.count {
            if(numDice > n) { diceImages[n] = "d\(randomNumbers[n])" }
        }
    }
    
    // Function for beginning a roll. Separated from the actual roll, because if the animation is being played, the dice need to be rolled
    // repeatedly.
    func startRoll() {
        // Abort if a roll was somehow triggered while one is already ongoing. This shouldn't be possible since the roll button gets
        // disabled during the roll, but it's here anyway.
        guard rollTask == nil else { return }
        rollTask = Task {
            if settingsData.playAnimations && !reduceMotion {
                for _ in 0..<10 {
                    if Task.isCancelled { return }
                    await MainActor.run {
                        self.roll()
                    }
                    try? await Task.sleep(nanoseconds: 100_000_000) // Why does this have to be nanoseconds? It's 0.1s.
                }
                await MainActor.run {
                    addHistoryEntry(settingsData: settingsData, results: "\(randomNumbers)", mode: "Dice Mode")
                    rollCount = 0
                    rollTask = nil
                }
            } else {
                await MainActor.run {
                    self.roll()
                    addHistoryEntry(settingsData: settingsData, results: "\(randomNumbers)", mode: "Dice Mode")
                    rollTask = nil
                }
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                VStack() {
                    // Draw the dice in a 6x3 grid by creating a row for each multiple of 3 dice, and then only drawing dice intended
                    // for that row in it.
                    ForEach(getItemGrid(numItems: numDice, numCols: 6), id: \.self) { row in
                        HStack() {
                            ForEach(row, id: \.self) { index in
                                Image(diceImages[index])
                                    .resizable()
                                    .frame(width: geometry.size.width / 9, height: geometry.size.width / 9)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                VStack(spacing: 10) {
                    Picker("Number of Dice:", selection: $numDice){
                        ForEach(1...18, id: \.self) { index in
                            Text("\(index)").tag(index)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(rollTask != nil)
                    HStack() {
                        Button(action:{
                            startRoll()
                        }) {
                            MonospaceSymbol(symbol: "play.fill")
                        }
                        .help("Roll the dice")
                        .buttonStyle(LargeSquareAccentButton())
                        .disabled(rollTask != nil)
                        Button(action:{
                            if (settingsData.confirmGenResets) { confirmReset = true }
                            else { resetGen() }
                        }) {
                            MonospaceSymbol(symbol: "clear.fill")
                        }
                        .help("Reset the dice roll")
                        .buttonStyle(LargeSquareAccentButton())
                        .alert("Confirm Reset", isPresented: $confirmReset, actions: {
                            Button("Confirm", role: .destructive) {
                                resetGen()
                            }
                        }, message: {
                            Text("Are you sure you want to reset the generator?")
                        })
                    }
                }
                .frame(width: geometry.size.width * 0.8)
            }
        }
        .navigationTitle("Dice")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showingExplainer = true
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .alert("Dice Mode", isPresented: $showingExplainer, actions: {}, message: {
            DiceExplainer()
        })
    }
}

#Preview {
    DiceMode().environmentObject(SettingsData())
}
