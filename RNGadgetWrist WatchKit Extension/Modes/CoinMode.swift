//
//  CoinMode.swift
//  RNGToolWrist
//
//  Created by Campbell on 2/27/25.
//

import SwiftUI
import WatchKit

struct CoinMode: View {
    @EnvironmentObject var settingsData: SettingsData
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @SceneStorage("CoinMode.coinFlip") private var coinFlip: Int = -1
    @State private var confirmReset: Bool = false
    @State private var showHint: Bool = true
    
    func resetGen() {
        coinFlip = -1
        confirmReset = false
    }
    
    func flipCoin() {
        WKInterfaceDevice.current().play(.click)
        withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.5)) {
            showHint = false
        }
        coinFlip = Int.random(in: 0...1)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack() {
                    Group {
                        if (coinFlip == -1) {
                            ZStack() {
                                Text("?")
                                    .font(.system(size: geometry.size.width / 5, design: .rounded))
                                Circle()
                                    .stroke(Color.primary, lineWidth: 3)
                            }
                            .frame(width: geometry.size.width / 2, height: geometry.size.width / 2)
                        }
                        else {
                            ZStack() {
                                Image(systemName: coinFlip == 1 ? "person" : "building.columns")
                                    .resizable()
                                    .frame(width: geometry.size.width / 4, height: geometry.size.width / 4)
                                Circle()
                                    .stroke(Color.primary, lineWidth: 3)
                            }
                            .frame(width: geometry.size.width / 2, height: geometry.size.width / 2)
                        }
                    }
                    .onTapGesture { flipCoin() }
                    if (showHint && settingsData.showModeHints) {
                        Text("Tap to flip a coin")
                            .foregroundColor(.secondary)
                    }
                    Button(action:{
                        if (settingsData.confirmGenResets) { confirmReset = true } else { resetGen() }
                    }) {
                        Image(systemName: "clear.fill")
                    }
                    .font(.system(size: 20, weight:.bold, design: .rounded))
                    .padding(.top, 10)
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
        .navigationTitle("Coins")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CoinMode().environmentObject(SettingsData())
}
