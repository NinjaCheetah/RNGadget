//
//  NumberMode.swift
//  RNGTool TV
//
//  Created by Campbell on 7/18/25.
//

import SwiftUI

struct NumberMode: View {
    @EnvironmentObject var settingsData: SettingsData
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @SceneStorage("NumberMode.randomNumber") private var randomNumber = 0
    @State private var maxNumber: Int = 100
    @State private var minNumber: Int = 0
    @State private var confirmReset: Bool = false
    @State private var showingExplainer: Bool = false
    
    func resetGen() {
        maxNumber = settingsData.maxNumberDefault
        minNumber = settingsData.minNumberDefault
        if (!reduceMotion && settingsData.playAnimations) { withAnimation { randomNumber = 0 } } else { randomNumber = 0 }
        confirmReset = false
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Text("\(randomNumber)")
                    // This code is to make the text showing the random number as big as possible while fitting the screen, fitting above
                    // the buttons, and not truncating.
                    .maxSizeText()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .onAppear { if (settingsData.saveModeStates == false) { randomNumber = 0 } } // Clear on load if we aren't meant to save
                    .contentTransition(.numericText(value: Double(randomNumber)))
                VStack(spacing: 10) {
                    HStack() {
                        VStack() {
                            Text("Maximum")
                            TextField("Enter a number", value: $maxNumber, format: .number)
                                .keyboardType(.numberPad)
                                .onAppear { maxNumber = settingsData.maxNumberDefault } // Load default maximum
                        }
                        VStack() {
                            Text("Minimum")
                            TextField("Enter a number", value: $minNumber, format: .number)
                                .keyboardType(.numberPad)
                                .onAppear { minNumber = settingsData.minNumberDefault } // Load default minimum
                        }
                    }
                    .frame(width: geometry.size.width * 0.8)
                    HStack() {
                        Button(action:{
                            if (maxNumber <= minNumber) { minNumber = maxNumber - 1 }
                            if (!reduceMotion && settingsData.playAnimations) {
                                withAnimation { randomNumber = Int.random(in: minNumber...maxNumber) } }
                            else { randomNumber = Int.random(in: minNumber...maxNumber) }
                            addHistoryEntry(settingsData: settingsData, results: "\(randomNumber)", mode: "Number Mode")
                        }) {
                            MonospaceSymbol(symbol: "play.fill")
                        }
                        .buttonStyle(LargeSquareAccentButton())
                        .help("Generate a number")
                        Button(action:{
                            if (settingsData.confirmGenResets) { confirmReset = true } else { resetGen() }
                        }) {
                            MonospaceSymbol(symbol: "clear.fill")
                        }
                        .buttonStyle(LargeSquareAccentButton())
                        .help("Reset custom values and output")
                        .alert("Confirm Reset", isPresented: $confirmReset, actions: {
                            Button("Confirm", role: .destructive) {
                                resetGen()
                            }
                        }, message: {
                            Text("Are you sure you want to reset the generator?")
                        })
                    }
                    .frame(width: geometry.size.width * 0.8)
                }
            }
            .navigationTitle("Numbers")
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
            .alert("Number Mode", isPresented: $showingExplainer, actions: {}, message: {
                NumberExplainer()
            })
        }
    }
}

#Preview {
    NumberMode().environmentObject(SettingsData())
}
