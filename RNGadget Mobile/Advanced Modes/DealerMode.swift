//
//  DealerMode.swift
//  RNGTool Mobile
//
//  Created by Campbell on 8/1/25.
//

import SwiftUI
import CoreHaptics
import UIKit

struct DealerHand: View {
    let handIndex: Int
    let hand: [String]
    let geometry: GeometryProxy
    let engine: CHHapticEngine?
    let drawCard: (Int) -> Void
    let drawDisabled: Bool
    
    func getCardWidth() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            90
        } else {
            68
        }
    }
    
    func getCardHeight() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            126
        } else {
            95
        }
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                HStack {
                    Text("Hand \(handIndex)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(hand.count)/12")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.secondary)
                }
                ZStack {
                    ForEach(0..<hand.count, id: \.self) { index in
                        Image(hand[index]).resizable()
                            .frame(width: getCardWidth(), height: getCardHeight())
                            .offset(x: CGFloat(20 * index), y: 0)
                    }
                    if hand.isEmpty {
                        Text("No Cards")
                            .foregroundStyle(.secondary)
                            .frame(height: 95)
                    }
                }
            }
            Button(action: {
                playHaptics(engine: engine, intensity: 1, sharpness: 0.75, count: 0.1)
                drawCard(handIndex - 1)
            }) {
                MonospaceSymbol(symbol: "plus")
                    .font(.title)
            }
            .disabled(drawDisabled)
        }
    }
}

struct DealerMode: View {
    @EnvironmentObject var settingsData: SettingsData
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var engine: CHHapticEngine?
    @State private var numCards: Int = 2
    @State private var confirmReset: Bool = false
    @State private var showingExplainer: Bool = false
    @State private var hands: [[String]] = [[]]
    @State private var deck: [String] = []
    @State private var drawCount: Int = 0
    @State private var drawTask: Task<Void, Never>? = nil
    
    func resetGen() {
        drawTask?.cancel()
        drawTask = nil
        numCards = 2
        for i in 0..<hands.count {
            hands[i].removeAll()
        }
        buildDeck()
        confirmReset = false
    }
    
    func deleteHands(at offsets: IndexSet) {
        hands.remove(atOffsets: offsets)
    }
    
    func buildDeck() {
        deck.removeAll()
        for suit in ["spades", "clubs", "diamonds", "hearts"] {
            for i in 2...10 {
                deck.append("\(i)-\(suit)")
            }
            for faceCard in ["ace", "jack", "queen", "king"] {
                deck.append("\(faceCard)-\(suit)")
            }
        }
    }
    
    func drawCards() {
        // Abort if a draw was somehow triggered while one is already ongoing. This shouldn't be possible since the draw button gets
        // disabled during the draw, but it's here anyway.
        guard drawTask == nil else { return }
        drawTask = Task {
            buildDeck()
            for i in 0..<hands.count {
                hands[i].removeAll()
                for _ in 0..<numCards {
                    hands[i].append(deck.remove(at: Int.random(in: 0..<deck.count)))
                }
            }
        }
        addHistoryEntry(
            settingsData: settingsData,
            results: "\(numCards) cards dealt to \(hands.count) hands",
            mode: "Dealer Mode"
        )
        drawTask = nil
    }
    
    func drawCard(index: Int) {
        guard hands[index].count < 12 else { return }
        hands[index].append(deck.remove(at: Int.random(in: 0..<deck.count)))
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        hands.append([])
                    }) {
                        Text("New Hand")
                    }
                    .disabled(hands.count >= 12)
                    Spacer()
                        .frame(maxWidth: .infinity)
                    EditButton()
                }
                .padding(.all, 8)
                .padding(.horizontal, 4)
                List {
                    ForEach(0..<hands.count, id: \.self) { index in
                        DealerHand(
                            handIndex: index + 1,
                            hand: hands[index],
                            geometry: geometry,
                            engine: engine,
                            drawCard: drawCard,
                            drawDisabled: deck.count < 1)
                    }
                    .onDelete(perform: deleteHands)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                VStack(spacing: 10) {
                    Text("\(deck.count) Cards Remaining")
                        .foregroundStyle(.secondary)
                    Text("Hand Size")
                    Picker("Hand Size", selection: $numCards){
                        Text("2").tag(2)
                        Text("3").tag(3)
                        Text("5").tag(5)
                        Text("7").tag(7)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: .infinity)
                    .disabled(drawTask != nil)
                    HStack {
                        Button(action:{
                            playHaptics(engine: engine, intensity: 1, sharpness: 0.75, count: 0.1)
                            drawCards()
                        }) {
                            MonospaceSymbol(symbol: "play.fill")
                        }
                        .buttonStyle(LargeSquareAccentButton())
                        .help("Draw cards for all hands")
                        .disabled(drawTask != nil)
                        .disabled(numCards * hands.count > 52)
                        Button(action:{
                            playHaptics(engine: engine, intensity: 1, sharpness: 0.75, count: 0.1)
                            for i in 0..<hands.count {
                                drawCard(index: i)
                            }
                        }) {
                            MonospaceSymbol(symbol: "plus")
                        }
                        .buttonStyle(LargeSquareAccentButton())
                        .help("Draw one card for all hands")
                        .disabled(drawTask != nil)
                        .disabled(hands.count > deck.count)
                        .frame(maxWidth: geometry.size.width * 0.25)
                    }
                    Button(action:{
                        playHaptics(engine: engine, intensity: 1, sharpness: 0.75, count: 0.2)
                        if (settingsData.confirmGenResets) { confirmReset = true } else { resetGen() }
                    }) {
                        MonospaceSymbol(symbol: "clear.fill")
                    }
                    .buttonStyle(LargeSquareAccentButton())
                    .help("Reset drawn hand")
                    .alert("Confirm Reset", isPresented: $confirmReset, actions: {
                        Button("Confirm", role: .destructive) {
                            resetGen()
                        }
                    }, message: {
                        Text("Are you sure you want to reset the generator?")
                    })
                }
                .padding(.top, 10)
                .frame(width: geometry.size.width * 0.85)
            }
        }
        .padding(.bottom, 10)
        .onAppear {
            prepareHaptics(engine: &engine)
            buildDeck()
        }
        .navigationTitle("Dealer")
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
        .alert("Dealer Mode", isPresented: $showingExplainer, actions: {}, message: {
            DealerExplainer()
        })
    }
}

#Preview {
    DealerMode().environmentObject(SettingsData())
}
