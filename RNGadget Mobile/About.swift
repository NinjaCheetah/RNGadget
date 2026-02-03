//
//  About.swift
//  RNGTool Mobile
//
//  Created by Campbell on 12/20/21.
//

import SwiftUI

struct About: View {
    let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    let buildNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    let copyright: String = Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as! String
    @State private var showCredits = false
    @Environment(\.openURL) var openURL
    
    var body: some View {
        GeometryReader { geometry in
            Form {
                #if os(iOS)
                HStack() {
                    Image("AltIcon").resizable()
                        .frame(width: geometry.size.width / 5, height: geometry.size.width / 5)
                    VStack(alignment: .leading) {
                        Text("RNGadget")
                        Text("Version \(appVersionString) (\(buildNumber))")
                            .foregroundColor(.secondary)
                        Text(copyright)
                            .foregroundColor(.secondary)
                    }
                }
                #endif
                #if os(watchOS)
                VStack(alignment: .leading) {
                    Text("RNGTool")
                    Text("Version \(appVersionString) (\(buildNumber))")
                        .foregroundColor(.secondary)
                }
                #endif
                Section(header: Text("Links")) {
                    Button(action:{
                        openURL(URL(string: "https://github.com/NinjaCheetah/RNGadget")!)
                    }) {
                        Label("RNGadget on GitHub", image: "GitHub")
                            .foregroundColor(.primary)
                    }
                    Button(action:{
                        openURL(URL(string: "https://ninjacheetah.dev")!)
                    }) {
                        Label {
                            Text("My Website")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "link.circle.fill").resizable()
                                .foregroundColor(.accentColor)
                                .symbolRenderingMode(.hierarchical)
                                .frame(width: 32, height: 32)
                        }
                    }
                }
                Section() {
                    Text("RNGTool was designed and developed with love by Campbell Bagley (NinjaCheetah)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    About()
}
