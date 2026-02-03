//
//  SettingsView.swift
//  RNGTool Mobile
//
//  Created by Campbell on 12/14/21.
//

import SwiftUI
#if os(iOS)
import UIKit
import CoreHaptics
#elseif os(watchOS)
import WatchKit
#endif

struct SettingsView: View {
    @EnvironmentObject var settingsData: SettingsData
    #if os(iOS)
    @State private var engine: CHHapticEngine?
    #elseif os(watchOS)
    @State private var kbReturnType = 0
    @State private var keyboardNumber = 0
    @State private var showNumKeyboard = false
    #endif
    @State private var showResetPrompt = false
    @State private var showAdvSettings = false
    // Enum for the @FocusState used to dismiss the keyboard when the done button is pressed
    enum Field {
        case maxNumber
        case minNumber
    }
    @FocusState private var fieldFocused: Field?

    var body: some View {
        Form {
            GeneralSettings()
            Section(header: Text("Number Mode"), footer: Text("The default maximum and minimum numbers when using Number Mode.")) {
                #if os(iOS)
                Text("Default Maximum Number")
                TextField("Required", value: $settingsData.maxNumberDefault, format: .number)
                    .keyboardType(.numberPad)
                    .focused($fieldFocused, equals: .maxNumber)
                Text("Default Minimum Number")
                TextField("Required", value: $settingsData.minNumberDefault, format: .number)
                    .keyboardType(.numberPad)
                    .focused($fieldFocused, equals: .minNumber)
                #elseif os(watchOS)
                // Use the custom watchOS number keyboard for easier number input, since the default keyboard is absolutely awful for just
                // entering numbers.
                Button(action: {
                    kbReturnType = 1
                    keyboardNumber = settingsData.maxNumberDefault
                    showNumKeyboard = true
                }) {
                    Text("Max: \(settingsData.maxNumberDefault)")
                }
                Button(action: {
                    kbReturnType = 2
                    keyboardNumber = settingsData.minNumberDefault
                    showNumKeyboard = true
                }) {
                    Text("Min: \(settingsData.minNumberDefault)")
                }
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
                                    settingsData.maxNumberDefault = keyboardNumber
                                }
                                else if(kbReturnType == 2) {
                                    settingsData.minNumberDefault = keyboardNumber
                                }
                                self.showNumKeyboard = false
                            }
                        }
                    })
                }
                #endif
                Button(action:{
                    #if os(iOS)
                    playHaptics(engine: engine, intensity: 0.8, sharpness: 0.5, count: 0.1)
                    #elseif os(watchOS)
                    WKInterfaceDevice.current().play(.click)
                    #endif
                    showResetPrompt = true
                }) {
                    Text("Reset")
                }
                .alert("Confirm Reset", isPresented: $showResetPrompt, actions: {
                    Button("Confirm", role: .destructive) {
                        settingsData.maxNumberDefault = 100
                        settingsData.minNumberDefault = 0
                        showResetPrompt = false
                    }
                }, message: {
                    Text("Are you sure you want to reset the minimum and maximum numbers to their defaults?")
                })
            }
            #if !os(watchOS)
            // Card mode only offers point value configuration, which isn't used on watchOS right now
            CardSettings()
            #endif
            Section(header: Text("More")) {
                #if os(iOS)
                // If we're on iPad, then display advanced settings as a sheet that pops up over everything.
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Button(action: {
                        showAdvSettings = true
                    }) {
                        Text("Show Advanced Settings")
                    }
                    .sheet(isPresented: $showAdvSettings, content: {
                        AdvancedSettingsiPad()
                    })
                // If we're not on iPad, then display a navigation link to the advanced settings screen.
                } else {
                    NavigationLink(destination: AdvancedSettings()) {
                        Image(systemName: "gearshape.2")
                            .foregroundColor(.accentColor)
                        Text("Advanced Settings")
                    }
                }
                #else
                // Always use the navigation link style when we're on watchOS (there's probably a nicer way to unify this).
                NavigationLink(destination: AdvancedSettings()) {
                    Image(systemName: "gearshape.2")
                        .foregroundColor(.accentColor)
                    Text("Advanced Settings")
                }
                #endif
                NavigationLink(destination: About()) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.accentColor)
                    Text("About RNGadget")
                }
            }
        }
        #if os(iOS)
        .onAppear { prepareHaptics(engine: &engine) }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    fieldFocused = .none // Dismisses the keyboard, since tapping away doesn't just do that on iOS
                }
            }
        }
        #endif
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

#if os(iOS)
struct AdvancedSettingsiPad: View {
    @Environment(\.presentationMode)
    var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationView {
            AdvancedSettings()
            .navigationBarItems(trailing: Button("Close", action: {
                self.presentationMode.wrappedValue.dismiss()
            }))
        }
    }
}
#endif

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(SettingsData())
    }
}
