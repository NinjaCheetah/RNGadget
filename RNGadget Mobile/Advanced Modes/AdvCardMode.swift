//
//  AdvCardMode.swift
//  RNGTool Mobile
//
//  Created by Campbell on 7/28/25.
//

import SwiftUI
import CoreHaptics

struct CardGrid: View {
    let cardImages: [String]
    let numCards: Int
    let geometry: GeometryProxy
    
    func getCardOffsetX(_ geometry: GeometryProxy, _ index: Int) -> CGFloat {
        let toRemove = (Double(index) / 7.0).rounded(.down) * 7
        return CGFloat((geometry.size.width * 0.085) * CGFloat(index - Int(toRemove)))
    }
    
    func getCardOffsetY(_ geometry: GeometryProxy, _ index: Int) -> CGFloat {
        let rowIndex = (Double(index) / 7.0).rounded(.down)
        return CGFloat((geometry.size.width * 0.085) * CGFloat(rowIndex))
    }

    var body: some View {
        VStack {
            ZStack {
                ForEach(0..<numCards, id: \.self) { index in
                    Image(cardImages[index]).resizable()
                        .frame(width: 180, height: 252)
                        .offset(x: getCardOffsetX(geometry, index), y: getCardOffsetY(geometry, index))
                }
            }
        }
    }
}

struct AdvCardMode: View {
    @EnvironmentObject var settingsData: SettingsData
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var engine: CHHapticEngine?
    @State private var pointValueStr: String = ""
    @State private var pointValues: [Int] = []
    @State private var numCards: Int = 0
    @State private var handSize: Int = 5
    @State private var confirmReset: Bool = false
    @State private var showingExplainer: Bool = false
    @State private var cardImages: [String] = []
    @State private var deck: [String] = []
    @State private var showDrawHint: Bool = true
    @State private var drawCount: Int = 0
    @State private var drawTask: Task<Void, Never>? = nil
    
    func clearVars() {
        drawTask?.cancel()
        drawTask = nil
        cardImages.removeAll()
        pointValues.removeAll()
        confirmReset = false
    }
    
    func resetGen() {
        clearHand()
        buildDeck()
    }
    
    func clearHand() {
        pointValueStr = ""
        if (settingsData.playAnimations && !reduceMotion) {
            Timer.scheduledTimer(withTimeInterval: 0.075, repeats: true) { timer in
                if(numCards == 0) {
                    timer.invalidate()
                    clearVars()
                }
                if(numCards > 0) { numCards -= 1 }
            }
        }
        else {
            numCards = 0
            clearVars()
        }
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
    
    func drawCard() {
        playHaptics(engine: engine, intensity: 1, sharpness: 0.75, count: 0.1)
        withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.5)) {
            self.showDrawHint = false
        }
        cardImages.append(deck.remove(at: Int.random(in: 0..<deck.count)))
        let cardDrawn = cardImages.last!.split(separator: "-")[0]
        if cardDrawn == "ace" {
            pointValues.append(settingsData.aceValue)
        } else if Int(cardDrawn) != nil {
            pointValues.append(Int(cardDrawn)!)
        } else {
            pointValues.append(10)
        }
        self.pointValueStr = "Point value(s): \(pointValues)"
        pointValueStr.removeAll(where: { removeCharacters.contains($0) } )
        numCards += 1
    }
    
    func drawCards() {
        // Abort if a draw was somehow triggered while one is already ongoing. This shouldn't be possible since the draw button gets
        // disabled during the draw, but it's here anyway.
        guard drawTask == nil else { return }
        drawTask = Task {
            withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.5)) {
                self.showDrawHint = false
            }
            pointValues.removeAll()
            for i in 0..<handSize {
                cardImages.append(deck.remove(at: Int.random(in: 0..<deck.count)))
                let cardDrawn = cardImages[i].split(separator: "-")[0]
                if cardDrawn == "ace" {
                    pointValues.append(settingsData.aceValue)
                } else if Int(cardDrawn) != nil {
                    pointValues.append(Int(cardDrawn)!)
                } else {
                    pointValues.append(10)
                }
            }
            self.pointValueStr = "Point value(s): \(pointValues)"
            pointValueStr.removeAll(where: { removeCharacters.contains($0) } )
            if settingsData.playAnimations && !reduceMotion {
                for _ in numCards..<cardImages.count {
                    if Task.isCancelled { return }
                    try? await Task.sleep(nanoseconds: 100_000_000) // Why does this have to be nanoseconds? It's 0.1s.
                    await MainActor.run {
                        // Play a single haptic tap for every draw in the animation. (It's more fun this way!)
                        playHaptics(engine: engine, intensity: 1, sharpness: 0.75, count: 0.1)
                        if(numCards < cardImages.count) { numCards += 1 }
                        self.drawCount += 1
                        if(drawCount == numCards) { self.drawCount = 0 }
                    }
                    playHaptics(engine: engine, intensity: 1, sharpness: 0.75, count: 0.1)
                }
            } else {
                numCards = cardImages.count
            }
            drawTask = nil
        }
    }
    
    func getCardPaddingX(geometry: GeometryProxy) -> CGFloat {
        return CGFloat((geometry.size.width * 0.085) * CGFloat(numCards < 8 ? numCards - 1 : 6))
    }
    
    func getCardPaddingY(geometry: GeometryProxy) -> CGFloat {
        let rowIndex = (Double(numCards) / 8.0).rounded(.down)
        return CGFloat((geometry.size.width * 0.085) * CGFloat(rowIndex))
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                VStack() {
                    ZStack(alignment: .center) {
                        Text("No Cards")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                        CardGrid(
                            cardImages: cardImages,
                            numCards: numCards,
                            geometry: geometry
                        )
                        .padding(.trailing, getCardPaddingX(geometry: geometry))
                        .padding(.bottom, getCardPaddingY(geometry: geometry))
                        .contextMenu {
                            Button(action: {
                                //copyToClipboard(item: handString)
                            }) {
                                Label("Copy", systemImage: "doc.on.doc")
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                VStack(spacing: 10) {
                    if settingsData.showPoints {
                        Text(pointValueStr)
                            .animation(.linear, value: pointValueStr) // Enables the use of .contentTransition()
                            .apply {
                                if #available(iOS 16.0, *) {
                                    $0.contentTransition(.numericText())
                                }
                                else {
                                    $0.animation(reduceMotion ? .none : .easeInOut(duration: 0.25), value: pointValueStr)
                                }
                            }
                    }
                    if (showDrawHint && settingsData.showModeHints) {
                        Text("Draw a hand, or draw individual cards")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    Text("Cards Remaining in Deck: \(deck.count)")
                        .font(.subheadline)
                    Text("Hand Size")
                    Picker("Hand Size", selection: $handSize){
                        ForEach(5...7, id: \.self) { index in
                            Text("\(index)").tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: .infinity)
                    .disabled(drawTask != nil)
                    HStack() {
                        Button(action:{
                            drawCards()
                        }) {
                            MonospaceSymbol(symbol: "play.fill")
                        }
                        .buttonStyle(LargeSquareAccentButton())
                        .frame(width: geometry.size.width * 0.25)
                        .help("Draw a hand")
                        .disabled(drawTask != nil)
                        .disabled(deck.isEmpty)
                        Button(action:{
                            drawCard()
                        }) {
                            MonospaceSymbol(symbol: "plus")
                        }
                        .buttonStyle(LargeSquareAccentButton())
                        .help("Draw a hand")
                        .disabled(drawTask != nil)
                        .disabled(deck.isEmpty)
                    }
                    HStack() {
                        Button(action:{
                            playHaptics(engine: engine, intensity: 1, sharpness: 0.75, count: 0.2)
                            if (settingsData.confirmGenResets) { confirmReset = true } else { resetGen() }
                        }) {
                            MonospaceSymbol(symbol: "clear.fill")
                        }
                        .buttonStyle(LargeSquareAccentButton())
                        .frame(width: geometry.size.width * 0.25)
                        .help("Reset drawn hand")
                        .alert("Confirm Reset", isPresented: $confirmReset, actions: {
                            Button("Confirm", role: .destructive) {
                                resetGen()
                            }
                        }, message: {
                            Text("Are you sure you want to reset the generator?")
                        })
                        Button(action: {
                            playHaptics(engine: engine, intensity: 1, sharpness: 0.75, count: 0.2)
                            clearHand()
                        }) {
                            MonospaceSymbol(symbol: "arrow.clockwise")
                        }
                        .buttonStyle(LargeSquareAccentButton())
                    }
                }
                .frame(width: geometry.size.width * 0.85)
            }
        }
        .padding(.bottom, 10)
        .onAppear {
            prepareHaptics(engine: &engine)
            buildDeck()
        }
        .navigationTitle("Cards+")
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
        .alert("Card+ Mode", isPresented: $showingExplainer, actions: {}, message: {
            Text("Advanced version of card mode featuring a persistent deck! Can you tell that this is primarily filler text?")
        })
    }
}

#Preview {
    AdvCardMode().environmentObject(SettingsData())
}
