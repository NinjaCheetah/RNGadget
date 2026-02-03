//
//  Haptics.swift
//  RNGTool Mobile
//
//  Created by Campbell on 4/19/22.
//

import Foundation
import CoreHaptics

func prepareHaptics(engine: inout CHHapticEngine?) {
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

    do {
        engine = try CHHapticEngine()
        try engine?.start()
    } catch {
        print("There was an error creating the engine: \(error.localizedDescription)")
    }
}

func playHaptics(engine: CHHapticEngine?, intensity: Float, sharpness: Float, count: Float) {
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
    var events = [CHHapticEvent]()

    for i in stride(from: 0, to: count, by: 0.1) {
        let intensitySet = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpnessSet = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensitySet, sharpnessSet], relativeTime: TimeInterval(i))
        events.append(event)
    }

    do {
        let pattern = try CHHapticPattern(events: events, parameters: [])
        let player = try engine?.makePlayer(with: pattern)
        try player?.start(atTime: 0)
    } catch {
        print("Failed to play pattern: \(error.localizedDescription).")
    }
}
