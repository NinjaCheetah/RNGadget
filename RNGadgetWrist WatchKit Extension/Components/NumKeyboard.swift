//
//  NumKeyboard.swift
//  RNGToolWrist WatchKit Extension
//
//  Created by Campbell on 8/23/22.
//

import SwiftUI
import WatchKit

// Button style used for the keyboard
struct NumKBButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Color.secondary)
            .cornerRadius(6)
            .monospacedDigit()
            .foregroundStyle(.primary)
    }
}

struct NumKeyboard: View {
    @Binding var targetNumber: Int
    @State private var currentNumberStr = ""
    
    func handleKeyPressed(key: String) {
        WKInterfaceDevice.current().play(.click)
        if (currentNumberStr == "0" && key != "0") { currentNumberStr += key }
        else { currentNumberStr += key }
        targetNumber = Int(currentNumberStr.prefix(19)) ?? 0
    }
    
    func handleDeletePressed() {
        WKInterfaceDevice.current().play(.click)
        currentNumberStr.remove(at: currentNumberStr.index(before: currentNumberStr.endIndex))
        if(currentNumberStr == "") { currentNumberStr = "0" }
        targetNumber = Int(currentNumberStr.prefix(19)) ?? 0
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack() {
                Spacer()
                HStack() {
                    Spacer()
                    Text("\(targetNumber)")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                }
                .frame(width: geometry.size.width)
                HStack {
                    Button {
                        handleKeyPressed(key: "1")
                    } label: {
                        Text("1")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(width: (geometry.size.width / 3) - 5, height: geometry.size.height / 5)
                    Button {
                        handleKeyPressed(key: "2")
                    } label: {
                        Text("2")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(width: (geometry.size.width / 3) - 5, height: geometry.size.height / 5)
                    Button {
                        handleKeyPressed(key: "3")
                    } label: {
                        Text("3")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(width: (geometry.size.width / 3) - 5, height: geometry.size.height / 5)
                }
                HStack {
                    Button {
                        handleKeyPressed(key: "4")
                    } label: {
                        Text("4")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(width: (geometry.size.width / 3) - 5, height: geometry.size.height / 5)
                    Button {
                        handleKeyPressed(key: "5")
                    } label: {
                        Text("5")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(width: (geometry.size.width / 3) - 5, height: geometry.size.height / 5)
                    Button {
                        handleKeyPressed(key: "6")
                    } label: {
                        Text("6")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(width: (geometry.size.width / 3) - 5, height: geometry.size.height / 5)
                }
                HStack {
                    Button {
                        handleKeyPressed(key: "7")
                    } label: {
                        Text("7")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(width: (geometry.size.width / 3) - 5, height: geometry.size.height / 5)
                    Button {
                        handleKeyPressed(key: "8")
                    } label: {
                        Text("8")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(width: (geometry.size.width / 3) - 5, height: geometry.size.height / 5)
                    Button {
                        handleKeyPressed(key: "9")
                    } label: {
                        Text("9")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(width: (geometry.size.width / 3) - 5, height: geometry.size.height / 5)
                }
                HStack {
                    Spacer()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .frame(width: (geometry.size.width / 3) - 5, height: geometry.size.height / 5)
                    Button {
                        handleKeyPressed(key: "0")
                    } label: {
                        Text("0")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(width: (geometry.size.width / 3) - 5, height: geometry.size.height / 5)
                    Button {
                        handleDeletePressed()
                    } label: {
                        Image(systemName: "delete.left")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(width: (geometry.size.width / 3) - 5, height: geometry.size.height / 5)
                }
            }
            .font(.system(size: 17, weight: .regular, design: .rounded))
            .frame(width: geometry.size.width, height: geometry.size.height)
            .buttonStyle(NumKBButtonStyle())
        }
        .onAppear {
            currentNumberStr = "\(targetNumber)"
        }
    }
}

struct NumKeyboard_Previews: PreviewProvider {
    @State static var exampleNum = 0
    
    static var previews: some View {
        NumKeyboard(targetNumber: $exampleNum)
    }
}
