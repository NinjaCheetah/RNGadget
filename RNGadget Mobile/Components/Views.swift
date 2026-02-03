//
//  Views.swift
//  RNGTool Mobile
//
//  Created by Campbell on 2/15/25.
//
//  Contains any iOS-exclusive custom view extensions, modifiers, or styles, as well as any functions related to visual content.
//

import SwiftUI
import UIKit
import Foundation

// Function that finds a good size for the dice in dice mode based off of the screen size. Also used in marble mode for the same purpose.
func getDieSize(geometry: GeometryProxy) -> CGFloat {
    // Currently using some different (and somewhat rough) calculations for iPad, because the die size calculations used for iPhone
    // don't work for the bigger screen, especially when you take the sidebar into account.
    let smallerLength = min(geometry.size.width, geometry.size.height)
    var dieSize: CGFloat
    if UIDevice.current.userInterfaceIdiom == .pad {
        dieSize = (smallerLength / 4.25) - 15
    }
    else {
        dieSize = (smallerLength / 3) - 15
    }
    return dieSize
}
