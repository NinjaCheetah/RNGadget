//
//  RPGDiceMode.swift
//  RNGTool Mobile
//
//  Created by Campbell on 8/2/25.
//

import SwiftUI
import CoreHaptics

struct RPGDiceRow: View {
    @State private var pickerVar: Int = 1
    let numDice: Int
    let diceImages: [String]
    let randomNumbers: [Int]
    let geometry: GeometryProxy

    var body: some View {
        HStack {
            VStack {
                // Draw the dice in a 3x3 grid by creating a row for each multiple of 3 dice, and then only drawing dice intended
                // for that row in it.
                ForEach(getItemGrid(numItems: numDice, numCols: 3), id: \.self) { row in
                    HStack() {
                        ForEach(row, id: \.self) { index in
                            ZStack {
                                Image(diceImages[index])
                                    .resizable()
                                    .frame(width: getDieSize(geometry: geometry), height: getDieSize(geometry: geometry))
                                Text("\(randomNumbers[index])")
                            }
                        }
                    }
                }
            }
            VStack {
                Text("This is the first die")
                HStack {
                    Text("Sides on Die:")
                    Picker("Number of dice", selection: $pickerVar) {
                        ForEach(1...6, id: \.self) {
                            Text("\($0)")
                        }
                    }
                }
            }
        }
    }
}

struct RPGDiceMode: View {
    @EnvironmentObject var settingsData: SettingsData
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var engine: CHHapticEngine?
    @State private var numDice: Int = 1
    @State private var confirmReset: Bool = false
    @State private var randomNumbers: [Int] = [0]
    @State private var diceImages: [String] = Array(repeating: "d8", count: 12)
    @State private var rollCount: Int = 0
    @State private var showingExplainer: Bool = false
    @State private var rollTask: Task<Void, Never>? = nil
    
    func resetGen() {
        rollTask?.cancel()
        rollTask = nil
        numDice = 1
        diceImages = Array(repeating: "d8", count: 12)
        confirmReset = false
    }
    
    // Roll function that generates a number for every die being shown in the range 1-6, and then sets each shown die to the image that
    // corresponds with the number rolled for it.
    func roll() {
        randomNumbers = (1...numDice).map { _ in Int.random(in: 1...6) }
        for n in 0..<randomNumbers.count{
            //if(numDice > n) { diceImages[n] = "d\(randomNumbers[n])" }
            if(numDice > n) { diceImages[n] = "d8" }
        }
    }
    
    // Function for beginning a roll. Separated from the actual roll, because if the animation is being played, the dice need to be rolled
    // repeatedly.
    func startRoll() {
        // Abort if a roll was somehow triggered while one is already ongoing. This shouldn't be possible since the roll button gets
        // disabled during the roll, but it's here anyway.
        guard rollTask == nil else { return }
        rollTask = Task {
            playHaptics(engine: engine, intensity: 1, sharpness: 0.75, count: 0.1)
            if settingsData.playAnimations && !reduceMotion {
                for _ in 0..<10 {
                    if Task.isCancelled { return }
                    await MainActor.run {
                        self.roll()
                    }
                    playHaptics(engine: engine, intensity: 1, sharpness: 0.75, count: 0.1)
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
                ScrollView {
                    VStack(alignment: .leading) {
                        RPGDiceRow(
                            numDice: numDice,
                            diceImages: diceImages,
                            randomNumbers: randomNumbers,
                            geometry: geometry
                        )
                        .padding(.all, 6)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 6)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // Tapping and shaking trigger the same code, but the shake gesture should only trigger a roll if motion input is
                // currently enabled.
                .onTapGesture { startRoll() }
                .onShake { if(settingsData.useMotionInput) { startRoll() } }
                VStack(spacing: 10) {
                    Text("Number of Dice")
                    Picker("Number of Dice", selection: $numDice){
                        ForEach(1...12, id: \.self) { index in
                            Text("\(index)").tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: .infinity)
                    .disabled(rollTask != nil)
                    Button(action:{
                        startRoll()
                    }) {
                        MonospaceSymbol(symbol: "play.fill")
                    }
                    .buttonStyle(LargeSquareAccentButton())
                    .help("Roll the dice")
                    .disabled(rollTask != nil)
                    Button(action:{
                        playHaptics(engine: engine, intensity: 1, sharpness: 0.75, count: 0.2)
                        if (settingsData.confirmGenResets) { confirmReset = true } else { resetGen() }
                    }) {
                        MonospaceSymbol(symbol: "clear.fill")
                    }
                    .buttonStyle(LargeSquareAccentButton())
                    .help("Reset dice count and roll")
                    .alert("Confirm Reset", isPresented: $confirmReset, actions: {
                        Button("Confirm", role: .destructive) {
                            resetGen()
                        }
                    }, message: {
                        Text("Are you sure you want to reset the generator?")
                    })
                }
                .frame(width: geometry.size.width * 0.85)
            }
        }
        .padding(.bottom, 10)
        .onAppear { prepareHaptics(engine: &engine) }
        .navigationTitle("RPG Dice")
        .navigationBarTitleDisplayMode(.inline)
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
        .alert("RPG Dice Mode", isPresented: $showingExplainer, actions: {}, message: {
            Text("uhhhhhh it's like dice but uhh for rpgs")
        })
    }
}

#Preview {
    RPGDiceMode().environmentObject(SettingsData())
}
