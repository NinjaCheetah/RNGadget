//
//  NumberMode.swift
//  RNGToolWrist WatchKit Extension
//
//  Created by Campbell on 1/31/22.
//

import SwiftUI
import WatchKit

struct NumberMode: View {
    @EnvironmentObject var settingsData: SettingsData
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @SceneStorage("NumberMode.randomNumber") private var randomNumber = 0
    @SceneStorage("NumberMode.maxNumber") private var maxNumber = 0
    @SceneStorage("NumberMode.minNumber") private var minNumber = 0
    @State private var confirmReset = false
    @State private var showHint = true
    @State private var showNumKeyboard = false
    @State private var keyboardNumber = 0
    @State private var kbReturnType = 0
    
    func resetGen() {
        randomNumber = 0
        maxNumber = settingsData.maxNumberDefault
        minNumber = settingsData.minNumberDefault
        confirmReset = false
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                Text("\(randomNumber)")
                    .maxSizeText()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.5)
                    .onTapGesture {
                        WKInterfaceDevice.current().play(.click)
                        withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.5)){
                            self.showHint = false
                        }
                        if (maxNumber <= minNumber) { minNumber = maxNumber - 1 }
                        randomNumber = Int.random(in: minNumber...maxNumber)
                    }
                if(showHint && settingsData.showModeHints) {
                    Text("Tap number to generate")
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack() {
                    Button(action: {
                        kbReturnType = 1
                        keyboardNumber = maxNumber
                        showNumKeyboard = true
                    }) {
                        Text("Max: \(maxNumber)")
                    }
                }
                VStack() {
                    Button(action: {
                        kbReturnType = 2
                        keyboardNumber = minNumber
                        showNumKeyboard = true
                    }) {
                        Text("Min: \(minNumber)")
                    }
                }
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
                .sheet(isPresented: $showNumKeyboard) {
                    NumKeyboard(targetNumber: $keyboardNumber)
                        .toolbar(content: {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") { self.showNumKeyboard = false }
                            }
                        })
                        .toolbar(content: {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") {
                                    if(kbReturnType == 1) {
                                        maxNumber = keyboardNumber
                                    }
                                    else if(kbReturnType == 2) {
                                        minNumber = keyboardNumber
                                    }
                                    self.showNumKeyboard = false
                                }
                            }
                        })
                }
            }
        }
        .navigationTitle("Numbers")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if (kbReturnType == 0) {
                if (maxNumber == 0 || settingsData.saveModeStates == false) { maxNumber = settingsData.maxNumberDefault }
                if (minNumber == 0 || settingsData.saveModeStates == false) { minNumber = settingsData.minNumberDefault }
            }
        }
    }
}

#Preview {
    NumberMode().environmentObject(SettingsData())
}
