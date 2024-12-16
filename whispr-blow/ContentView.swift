//
//  ContentView.swift
//  whispr-blow
//
//  Created by Max Wofford on 12/16/24.
//

import SwiftUI


struct ContentView: View {
    @State var listening: Bool = false
    @State var audioTranscription: String?
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            Button(listening ? "Stop listening" : "Listen") {
                self.listening.toggle()
                if (listening) {
                    
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

