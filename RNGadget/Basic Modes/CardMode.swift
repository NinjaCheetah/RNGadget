//
//  CardMode.swift
//  RNGTool
//
//  Created by Campbell on 9/5/21.
//

import SwiftUI

struct CardMode: View {
    @EnvironmentObject var settingsData: SettingsData
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var pointValueStr: String = ""
    @State private var pointValues: [Int] = [0]
    @State private var numCards: Int = 1
    @State private var cardsToDisplay: Int = 1
    @State private var confirmReset: Bool = false
    @State private var showingExplainer: Bool = false
    @State private var cardImages: [String] = Array(repeating: "ace-spades", count: 12)
    @State private var deck: [String] = []
    @State private var handString: String = ""
    @State private var showDrawHint: Bool = true
    @State private var drawCount: Int = 0
    @State private var drawTask: Task<Void, Never>? = nil
    
    func clearVars() {
        drawTask?.cancel()
        drawTask = nil
        cardImages = Array(repeating: "ace-spades", count: 12)
        confirmReset = false
    }
    
    func resetGen() {
        pointValueStr = ""
        numCards = 1
        if (settingsData.playAnimations && !reduceMotion) {
            Timer.scheduledTimer(withTimeInterval: 0.075, repeats: true) { timer in
                if(cardsToDisplay == 1) {
                    timer.invalidate()
                    clearVars()
                }
                if(cardsToDisplay > 1) { cardsToDisplay -= 1 }
            }
        }
        else {
            cardsToDisplay = 1
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
    
    func drawCards() {
        // Abort if a draw was somehow triggered while one is already ongoing. This shouldn't be possible since the draw button gets
        // disabled during the draw, but it's here anyway.
        guard drawTask == nil else { return }
        drawTask = Task {
            withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.5)) {
                self.showDrawHint = false
            }
            buildDeck()
            pointValues.removeAll()
            for i in 0..<numCards {
                cardImages[i] = deck.remove(at: Int.random(in: 0..<deck.count))
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
            cardsToDisplay = 1
            if settingsData.playAnimations && !reduceMotion {
                for _ in 0..<numCards {
                    if Task.isCancelled { return }
                    try? await Task.sleep(nanoseconds: 100_000_000) // Why does this have to be nanoseconds? It's 0.1s.
                    await MainActor.run {
                        if(cardsToDisplay < numCards) { cardsToDisplay += 1 }
                        self.drawCount += 1
                        if(drawCount == numCards) { self.drawCount = 0 }
                    }
                }
            } else {
                cardsToDisplay = numCards
            }
            handString = ""
            for i in 0..<numCards {
                let cardValue = cardImages[i].split(separator: "-")[0]
                let cardSuit = cardImages[i].split(separator: "-")[1]
                switch cardValue {
                    case "ace":
                        handString += "A"
                    case "jack":
                        handString += "J"
                    case "queen":
                        handString += "Q"
                    case "king":
                        handString += "K"
                    default:
                        handString += cardValue
                }
                switch cardSuit {
                    case "spades":
                        handString += "♠️, "
                    case "clubs":
                        handString += "♣️, "
                    case "diamonds":
                        handString += "♦️, "
                    case "hearts":
                        handString += "♥️, "
                    default:
                        continue
                }
            }
            handString.removeLast(2)
            addHistoryEntry(settingsData: settingsData, results: handString, mode: "Card Mode")
            drawTask = nil
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                VStack() {
                    VStack(alignment: .leading) {
                        ZStack(){
                            ForEach(0..<cardsToDisplay, id: \.self) { index in
                                Image(cardImages[index]).resizable()
                                    .frame(width: 180, height: 252)
                                    .offset(x: CGFloat((geometry.size.width * 0.065) * CGFloat(index)), y: 0)
                            }
                        }
                    }
                    .contextMenu {
                        Button(action: {
                            copyToClipboard(item: handString)
                        }) {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                    }
                    .onTapGesture { drawCards() }
                    .padding(.trailing, CGFloat((geometry.size.width * 0.065) * CGFloat((cardsToDisplay - 1))))
                    if settingsData.showPoints {
                        Text(pointValueStr)
                            .animation(.linear, value: pointValueStr) // Enables the use of .contentTransition()
                            .apply {
                                if #available(macOS 13.0, *) {
                                    $0.contentTransition(.numericText())
                                }
                                else {
                                    $0.animation(reduceMotion ? .none : .easeInOut(duration: 0.25), value: pointValueStr)
                                }
                            }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                VStack(spacing: 10) {
                    if (showDrawHint && settingsData.showModeHints) {
                        Text("Tap the card to draw a hand")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    Picker("Number of Cards:", selection: $numCards) {
                        ForEach(1...12, id: \.self) { index in
                            Text("\(index)").tag(index)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(drawTask != nil)
                    Button(action:{
                        drawCards()
                    }) {
                        MonospaceSymbol(symbol: "play.fill")
                    }
                    .buttonStyle(LargeSquareAccentButton())
                    .help("Draw a hand")
                    .disabled(drawTask != nil)
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
                .frame(width: geometry.size.width * 0.4)
            }
        }
        .padding(.bottom, 10)
        .navigationTitle("Cards")
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
        .alert("Card Mode", isPresented: $showingExplainer, actions: {}, message: {
            CardExplainer()
        })
    }
}

#Preview {
    CardMode().environmentObject(SettingsData())
}
