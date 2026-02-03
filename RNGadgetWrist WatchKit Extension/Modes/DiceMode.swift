//
//  DiceMode.swift
//  RNGToolWrist WatchKit Extension
//
//  Created by Campbell on 1/31/22.
//

import SwiftUI
import WatchKit

struct DiceMode: View {
    @EnvironmentObject var settingsData: SettingsData
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var numDice: Int = 1
    @State private var confirmReset: Bool = false
    @State private var randomNumbers: [Int] = [0]
    @State private var diceImages: [String] = Array(repeating: "d6-1", count: 3)
    @State private var rollCount: Int = 0
    @State private var showRollHint: Bool = true
    @State private var rollTask: Task<Void, Never>? = nil
    
    func resetGen() {
        rollTask?.cancel()
        rollTask = nil
        numDice = 1
        diceImages = Array(repeating: "d6-1", count: 3)
        confirmReset = false
    }
    
    func roll() {
        randomNumbers = (0..<numDice).map { _ in Int.random(in: 1...6) }
        for n in 0..<randomNumbers.count {
            if (numDice>n) {diceImages[n]="d6-\(randomNumbers[n])"}
        }
    }
    
    func startRoll() {
        guard rollTask == nil else { return }
        rollTask = Task {
            WKInterfaceDevice.current().play(.click)
            await MainActor.run {
                withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.5)) { self.showRollHint = false }
            }
            if settingsData.playAnimations && !reduceMotion {
                for _ in 0..<10 {
                    if Task.isCancelled { return }
                    await MainActor.run {
                        self.roll()
                        rollCount += 1
                    }
                    try? await Task.sleep(nanoseconds: 100_000_000) // Why does this have to be nanoseconds? It's 0.1s.
                }
                await MainActor.run {
                    rollCount = 0
                    rollTask = nil
                }
            } else {
                await MainActor.run {
                    self.roll()
                    rollTask = nil
                }
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .center) {
                    HStack() {
                        ForEach(0..<numDice, id: \.self) { index in
                          Image(diceImages[index])
                            .resizable()
                            .frame(width: (geometry.size.width / 3) - 10, height: (geometry.size.width / 3) - 10)
                        }
                    }
                    .onTapGesture { startRoll() }
                    if (showRollHint && settingsData.showModeHints) {
                        Text("Tap dice to roll")
                            .foregroundColor(.secondary)
                    }
                    Picker("Number of Dice", selection: $numDice){
                        ForEach(1...3, id: \.self) { index in
                            Text("\(index)").tag(index)
                        }
                    }
                    .frame(width: geometry.size.width - 15, height: geometry.size.height / 2.5)
                    .disabled(rollTask != nil)
                    Button(action:{
                        if (settingsData.confirmGenResets) { confirmReset = true } else { resetGen() }
                    }) {
                        Image(systemName: "clear.fill")
                    }
                    .font(.system(size: 20, weight:.bold, design: .rounded))
                    .foregroundColor(.red)
                    .alert("Confirm Reset", isPresented: $confirmReset, actions: {
                        Button("Confirm", role: .destructive) {
                            resetGen()
                        }
                    }, message: {
                        Text("Are you sure you want to reset the generator?")
                    })
                }
            }
            .frame(width: geometry.size.width)
        }
        .navigationTitle("Dice")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DiceMode().environmentObject(SettingsData())
}
