//
//  MarbleMode.swift
//  RNGTool Mobile
//
//  Created by Campbell on 12/19/21.
//

import SwiftUI
import UIKit
import CoreHaptics

struct MarbleMode: View {
    @EnvironmentObject var settingsData: SettingsData
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var engine: CHHapticEngine?
    @State private var numMarbles: Int = 1
    @State private var rollCount: Int = 0
    @State private var randomLetters: [String] = Array(repeating: "A", count: 9)
    @State private var confirmReset: Bool = false
    @State private var showingExplainer: Bool = false
    @State private var showRollHint: Bool = true
    @State private var letters: [String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    @State private var rollTask: Task<Void, Never>? = nil
    
    func resetGen() {
        rollTask?.cancel()
        rollTask = nil
        numMarbles = 1
        randomLetters = Array(repeating: "A", count: 9)
        confirmReset = false
    }

    func roll() {
        for i in 0..<numMarbles {
            randomLetters[i] = letters[Int.random(in: 0...25)]
        }
    }
    
    func startRoll() {
        // Abort if a roll was somehow triggered while one is already ongoing. This shouldn't be possible since the roll button gets
        // disabled during the roll, but it's here anyway.
        guard rollTask == nil else { return }
        rollTask = Task {
            playHaptics(engine: engine, intensity: 1, sharpness: 0.75, count: 0.1)
            await MainActor.run {
                withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.5)) { self.showRollHint = false }
            }
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
                    addHistoryEntry(settingsData: settingsData, results: "\(randomLetters)", mode: "Marble Mode")
                    rollCount = 0
                    rollTask = nil
                }
            } else {
                await MainActor.run {
                    self.roll()
                    addHistoryEntry(settingsData: settingsData, results: "\(randomLetters)", mode: "Marble Mode")
                    rollTask = nil
                }
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                VStack() {
                    // Same as the dice, draw the marbles in a 3x3 grid by creating a row for each multiple of 3 marbles, and then only
                    // drawing marbles intended for that row in it.
                    ForEach(getItemGrid(numItems: numMarbles, numCols: 3), id: \.self) { row in
                        HStack() {
                            ForEach(row, id: \.self) { index in
                                ZStack() {
                                    Text("\(randomLetters[index])")
                                        // Font calculations are split because using a larger portion of the screen width on iPhone
                                        // produces a better result compared to iPad.
                                        .font(.system(size: (UIDevice.current.userInterfaceIdiom == .pad) ? (geometry.size.width / 14) : (geometry.size.width / 10)))
                                    Circle()
                                        .stroke(Color.primary, lineWidth: 4)
                                }
                                .frame(width: getDieSize(geometry: geometry), height: getDieSize(geometry: geometry))
                                // Making the content shape a rectangle and attaching the onTapGesture here means that you can tap
                                // anywhere in the invisible rectangle that the marble fits in to roll.
                                .contentShape(Rectangle())
                                .onTapGesture { startRoll() }
                            }
                        }
                        
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contextMenu {
                    Button(action: {
                        var randomLetterCopyStr = "\(randomLetters)"
                        randomLetterCopyStr.removeAll(where: { removeCharacters.contains($0) } )
                        copyToClipboard(item: "\(randomLetterCopyStr)")
                    }) {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                }
                // Tapping and shaking are effectively the same, but shaking should only actually trigger a roll if we're supposed to be
                // reading motion input.
                .onShake { if(settingsData.useMotionInput) { startRoll() } }
                VStack(spacing: 10) {
                    if(showRollHint && settingsData.showModeHints) {
                        Text("Tap marble to roll")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    Text("Number of Marbles")
                    Picker("Number of Marbles", selection: $numMarbles){
                        ForEach(1...9, id: \.self) { index in
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
                    .help("Roll some marbles")
                    .disabled(rollTask != nil)
                    Button(action:{
                        playHaptics(engine: engine, intensity: 1, sharpness: 0.75, count: 0.2)
                        if( settingsData.confirmGenResets) { confirmReset = true } else { resetGen() }
                    }) {
                        MonospaceSymbol(symbol: "clear.fill")
                    }
                    .buttonStyle(LargeSquareAccentButton())
                    .help("Reset rolled marbles")
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
        .navigationTitle("Marbles")
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
        .alert("Marble Mode", isPresented: $showingExplainer, actions: {}, message: {
            MarbleExplainer()
        })
    }
}

struct MarbleMode_Previews: PreviewProvider {
    static var previews: some View {
        MarbleMode().environmentObject(SettingsData())
    }
}
