//
//  ContentView.swift
//  whispr-blow
//
//  Created by Max Wofford on 12/16/24.
//

import SwiftUI
import WhisperKit
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import AVFoundation
import CoreML


struct ContentView: View {
    @State private var whisperKit: WhisperKit?
    #if os(macOS)
    @State private var audioDevices: [AudioDevice]?
    #endif
    @State private var isRecording: Bool = false
    @State private var isTranscribing: Bool = false
    @State private var currentText: String = ""
    
    @State var listening: Bool = false
    @State var audioTranscription: String?
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            ModelLoaderView(whisperKit: $whisperKit)
            
            Button(listening ? "Stop listening" : "Listen") {
                self.listening.toggle()
            }
        }
        .padding()
    }
}

struct ModelLoaderView: View {
    enum Statuses {
        case loading
        case success
        case failure
    }
    
    let models: [String] =
        [
            "tiny.en",
            "tiny",
            "small.en",
            "small",
        ]
    
    @State var modelName = "tiny"
    @State var status: Statuses = .loading
    @Binding var whisperKit: WhisperKit?
    

    func initModel() {
        Task { do {
            status = .loading
            whisperKit = try await WhisperKit(model: modelName)
            status = .success
        } catch {
            print(error, "yoloswagmoneybag")
            status = .failure
        }}
    }

    var body: some View {
        HStack {
            Picker("Model", selection: $modelName) {
                ForEach(models, id: \.self) { model in
                    Text(model)
                }
            }.onChange(of: modelName) {
                initModel()
            }.task { do {
                initModel()
             }}

            Spacer()
            
            switch status {
            case .loading: ProgressView().controlSize(.small)
            case .success: Image(systemName: "circle.badge.checkmark.fill")
                    .imageScale(.large)
            case .failure: Image(systemName: "circle.badge.xmark.fill")
                    .imageScale(.large)
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    ContentView()
}

