//
//  CoinMode.swift
//  RNGTool Mobile
//
//  Created by Campbell on 2/15/25.
//

import SwiftUI
import CoreHaptics

struct CoinMode: View {
    @EnvironmentObject var settingsData: SettingsData
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @SceneStorage("CoinMode.coinCount") private var coinCount: Int = 0
    @SceneStorage("CoinMode.headsCount") private var headsCount: Int = 0
    @SceneStorage("CoinMode.tailsCount") private var tailsCount: Int = 0
    @State private var numCoins: Int = 1
    @State private var flipCount: Int = 0
    @State private var engine: CHHapticEngine?
    @State private var confirmReset: Bool = false
    @State private var showingExplainer: Bool = false
    @State private var flipTask: Task<Void, Never>? = nil
    
    func resetGen() {
        flipTask?.cancel()
        flipTask = nil
        headsCount = 0
        tailsCount = 0
        coinCount = 0
        numCoins = 1
        confirmReset = false
    }
    
    func flipCoin() {
        let coinInt = Int.random(in: 0...1)
        if (coinInt == 1) {
            headsCount += 1
        } else {
            tailsCount += 1
        }
        coinCount += 1
    }
    
    func flipCoins() {
        // No more spam flipping allowed!
        guard flipTask == nil else { return }
        flipTask = Task {
            playHaptics(engine: engine, intensity: 1, sharpness: 0.75, count: 0.1)
            for _ in 0..<numCoins {
                if Task.isCancelled { return }
                await MainActor.run {
                    self.flipCoin()
                    self.flipCount += 1
                }
                // Play a single haptic tap for every coin flipped. (Just like with the dice, it's more fun this way!)
                playHaptics(engine: engine, intensity: 1, sharpness: 0.75, count: 0.1)
                try? await Task.sleep(nanoseconds: 75_000_000) // Why does this have to be nanoseconds? It's 0.075s.
            }
            await MainActor.run {
                addHistoryEntry(settingsData: settingsData, results: "H: \(headsCount), T: \(tailsCount)", mode: "Coin Mode")
                flipCount = 0
                flipTask = nil
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                VStack() {
                    Text("Heads: \(headsCount)")
                    // This code is to make the text showing the random number as big as possible while fitting the screen, fitting above
                    // the buttons, and not truncating.
                        .maxSizeText()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .contextMenu {
                            Button(action: {
                                copyToClipboard(item: "Heads: \(headsCount)")
                            }) {
                                Text("Copy")
                                Image(systemName: "document.on.document")
                            }
                        }
                    Text("Tails: \(tailsCount)")
                    // This code is to make the text showing the random number as big as possible while fitting the screen, fitting above
                    // the buttons, and not truncating.
                        .maxSizeText()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .contextMenu {
                            Button(action: {
                                copyToClipboard(item: "Tails: \(tailsCount)")
                            }) {
                                Text("Copy")
                                Image(systemName: "document.on.document")
                            }
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    // Clear out remembered values if we aren't supposed to save them
                    if (settingsData.saveModeStates == false) {
                        coinCount = 0
                        headsCount = 0
                        tailsCount = 0
                    }
                }
                VStack(spacing: 10) {
                    Text("Total Coins Flipped: \(coinCount)")
                        .font(.headline)
                    HStack() {
                        Text("Number of Coins")
                        Picker("Number of Coins", selection: $numCoins){
                            ForEach(1...50, id: \.self) { index in
                                Text("\(index)").tag(index)
                            }
                        }
                        .disabled(flipTask != nil)
                    }
                    .padding(.horizontal, geometry.size.width * 0.075)
                    Button(action:{
                        flipCoins()
                    }) {
                        MonospaceSymbol(symbol: "play.fill")
                    }
                    .buttonStyle(LargeSquareAccentButton())
                    .help("Flip some coins")
                    .disabled(flipTask != nil)
                    Button(action:{
                        playHaptics(engine: engine, intensity: 1, sharpness: 0.75, count: 0.2)
                        if (settingsData.confirmGenResets) { confirmReset = true } else { resetGen() }
                    }) {
                        MonospaceSymbol(symbol: "clear.fill")
                    }
                    .buttonStyle(LargeSquareAccentButton())
                    .help("Reset coin flips")
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
        .navigationTitle("Coins")
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
        .alert("Coin Mode", isPresented: $showingExplainer, actions: {}, message: {
            CoinExplainer()
        })
    }
}

#Preview {
    CoinMode().environmentObject(SettingsData())
}
