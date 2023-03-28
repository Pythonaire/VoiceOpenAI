//
//  VoiceOpenAIApp.swift
//  VoiceOpenAI
//
//  Created by Peter Wiechmann on 16.03.23.
//

import SwiftUI

@main
struct VoiceOpenAIApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    var body: some Scene {
        
        WindowGroup {
            /*
            if apiKey != "" {
                ContentView(requ: Requester(), st: SpeechAndText())
                    .edgesIgnoringSafeArea(.all)
                    .background(VisualEffects().ignoresSafeArea(.all))
    
            } else {
                APIView()
                 .ignoresSafeArea()
                }
             */
            
        }
        .commands {
                    CommandGroup(replacing: .newItem, addition: { })
                    }
        }
    }

