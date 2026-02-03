//
//  MarbleMode.swift
//  RNGToolWrist WatchKit Extension
//
//  Created by Campbell on 1/31/22.
//

import SwiftUI
import WatchKit

struct MarbleMode: View {
    @EnvironmentObject var settingsData: SettingsData
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var numMarbles = 1
    @State private var randomLetters: [String] = Array(repeating: "A", count: 3)
    @State private var confirmReset = false
    @State private var showRollHint = true
    @State private var rollCount = 0
    @State private var letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    @State private var rollTask: Task<Void, Never>? = nil
    
    func resetGen() {
        rollTask?.cancel()
        rollTask = nil
        numMarbles = 1
        randomLetters = Array(repeating: "A", count: 3)
        confirmReset = false
    }
    
    func roll() {
        for i in 0..<numMarbles {
            randomLetters[i] = letters[Int.random(in: 0...25)]
        }
    }
    
    func startRoll() {
        guard rollTask == nil else { return }
        rollTask = Task {
            WKInterfaceDevice.current().play(.click)
            await MainActor.run {
                withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.5)) { self.showRollHint = false }
            }
            if settingsData.playAnimations && !reduceMotion {
                for _ in 0..<10 {
                    if Task.isCancelled { return }
                    await MainActor.run {
                        self.roll()
                    }
                    try? await Task.sleep(nanoseconds: 100_000_000) // Why does this have to be nanoseconds? It's 0.1s.
                }
                await MainActor.run {
                    rollCount = 0
                    rollTask = nil
                }
            } else {
                await MainActor.run {
                    self.roll()
                    rollTask = nil
                }
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                HStack(){
                    ForEach(0..<numMarbles, id: \.self) { index in
                        ZStack() {
                            Text("\(randomLetters[index])")
                                .font(.title3)
                            Circle()
                                .stroke(Color.primary, lineWidth: 3)
                        }
                        .frame(width: (geometry.size.width / 3) - 10, height: (geometry.size.width / 3) - 10)
                    }
                }
                .padding(.top, 4)
                .onTapGesture { startRoll() }
                if(showRollHint && settingsData.showModeHints) {
                    Text("Tap dice to roll")
                        .foregroundColor(.secondary)
                }
                Picker("Number of Marbles", selection: $numMarbles){
                    ForEach(1...3, id: \.self) { index in
                        Text("\(index)").tag(index)
                    }
                }
                .frame(width: geometry.size.width - 15, height: geometry.size.height / 2.5)
                .disabled(rollTask != nil)
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
            }
            .frame(width: geometry.size.width)
        }
        .navigationTitle("Marbles")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MarbleMode_Previews: PreviewProvider {
    static var previews: some View {
        MarbleMode().environmentObject(SettingsData())
    }
}
