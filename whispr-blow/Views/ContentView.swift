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
//    @State private var audioDevices: [AudioDevice]?
    #endif
    @State private var isRecording: Bool = false
    @State private var isTranscribing: Bool = false
    @State private var currentText: String = ""
    
    @State var listening: Bool = false
    @State var audioTranscription: String?
    
    func startRecording() {
        if let audioProcessor = whisperKit?.audioProcessor {
            Task(priority: .userInitiated) {
                guard await AudioProcessor.requestRecordPermission() else {
                    print("Microphone access was not granted")
                    return
                }

                #if os(macOS)
                let audioDevices: [AudioDevice] = AudioProcessor.getAudioDevices()
                let device = audioDevices.first
                
                // There is no built-in microphone
                if (device == nil || device?.id == nil) {
                    throw WhisperError.microphoneUnavailable()
                }
                #endif
                
                try? audioProcessor.startRecordingLive(inputDeviceID: device?.id, callback: { _ in
                    DispatchQueue.main.async {
                        
                    }
                })
            }
        }
    }
                                                       
    func stopRecording() {
        if let audioProcessor = whisperKit?.audioProcessor {
            audioProcessor.stopRecording()
        }
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            ModelLoaderView(whisperKit: $whisperKit)
            
            Button(listening ? "Stop listening" : "Listen") {
                self.listening.toggle()
                if listening {
                    startRecording()
                } else {
                    stopRecording()
                }
            }
            Text(audioTranscription ?? "")
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
            case .loading: Image(systemName: "progress.indicator")
                    .imageScale(.large)
                    .symbolEffect(.variableColor.iterative, isActive: true)
            case .success: Image(systemName: "circle.badge.checkmark")
                    .symbolRenderingMode(.hierarchical)
                    .imageScale(.large)
                    .symbolEffect(.bounce.byLayer.down, value: status)
            case .failure: Image(systemName: "circle.badge.xmark")
                    .symbolRenderingMode(.multicolor)
                    .imageScale(.large)
                    .foregroundStyle(.red)
                    .symbolEffect(.bounce.byLayer.down, value: status)
            }
        }
    }
}

#Preview {
    ContentView()
}

