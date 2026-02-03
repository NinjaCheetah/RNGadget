//
//  DealerMode.swift
//  RNGTool
//
//  Created by Campbell on 8/2/25.
//

import SwiftUI

struct DealerHand: View {
    let handIndex: Int
    let hand: [String]
    let geometry: GeometryProxy
    let drawCard: (Int) -> Void
    let deleteHand: (Int) -> Void
    let drawDisabled: Bool
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                HStack {
                    Text("Hand \(handIndex)")
                    Text("\(hand.count)/12")
                        .foregroundStyle(.secondary)
                    Button(action: {
                        deleteHand(handIndex - 1)
                    }) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                    Spacer()
                        .frame(maxWidth: .infinity)
                }
                ZStack {
                    ForEach(0..<hand.count, id: \.self) { index in
                        Image(hand[index]).resizable()
                            .frame(width: 90, height: 126)
                            .offset(x: CGFloat(20 * index), y: 0)
                    }
                    if hand.isEmpty {
                        Text("No Cards")
                            .foregroundStyle(.secondary)
                            .frame(height: 126)
                    }
                }
            }
            Button(action: {
                drawCard(handIndex - 1)
            }) {
                MonospaceSymbol(symbol: "plus")
                    .font(.title)
            }
            .buttonStyle(.borderless)
            .foregroundStyle(Color.accentColor)
            .disabled(drawDisabled)
        }
    }
}

struct DealerMode: View {
    @EnvironmentObject var settingsData: SettingsData
    @Environment(\.accessibilityReduceMotion) var reduceMotion
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
    
    func deleteHand(index: Int) {
        hands.remove(at: index)
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
                    Text("\(deck.count) Cards Remaining")
                        .foregroundStyle(.secondary)
                    Spacer()
                        .frame(maxWidth: .infinity)
                }
                .padding(.all, 8)
                .padding(.horizontal, 4)
                List {
                    ForEach(0..<hands.count, id: \.self) { index in
                        DealerHand(
                            handIndex: index + 1,
                            hand: hands[index],
                            geometry: geometry,
                            drawCard: drawCard,
                            deleteHand: deleteHand,
                            drawDisabled: deck.count < 1)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                VStack(spacing: 10) {
                    Picker("Hand Size:", selection: $numCards){
                        Text("2").tag(2)
                        Text("3").tag(3)
                        Text("5").tag(5)
                        Text("7").tag(7)
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(drawTask != nil)
                    HStack {
                        Button(action:{
                            drawCards()
                        }) {
                            MonospaceSymbol(symbol: "play.fill")
                        }
                        .buttonStyle(LargeSquareAccentButton())
                        .help("Draw cards for all hands")
                        .disabled(drawTask != nil)
                        .disabled(numCards * hands.count > 52)
                        Button(action:{
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
                        .frame(maxWidth: geometry.size.width * 0.1)
                    }
                    Button(action:{
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
                .frame(width: geometry.size.width * 0.4)
            }
        }
        .padding(.bottom, 10)
        .onAppear { buildDeck() }
        .navigationTitle("Dealer")
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
