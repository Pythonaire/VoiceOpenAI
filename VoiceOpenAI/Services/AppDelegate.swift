//
//  AppDelegate.swift
//  VoiceOpenAI
//
//
//
import SwiftUI
import Speech


class AppDelegate: NSObject, NSApplicationDelegate,  NSWindowDelegate  {
    @AppStorage("apiKey") var apiKey = ""
    @AppStorage("permission") var permission: Bool = false
    @AppStorage("microphone") var microphone: Bool = false
    
    private var floatingPanel:  NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
            floatingPanel = NSApplication.shared.windows.first
            let contentRect = NSRect(x: 0, y: 0, width: 800, height: .zero)
            floatingPanel.setContentSize(contentRect.size)
            floatingPanel.isReleasedWhenClosed = false
            floatingPanel.hidesOnDeactivate = true
            floatingPanel.collectionBehavior.insert(.fullScreenAuxiliary)
            floatingPanel.standardWindowButton(.closeButton)?.isHidden = true
            floatingPanel.standardWindowButton(.miniaturizeButton)?.isHidden = true
            floatingPanel.standardWindowButton(.zoomButton)?.isHidden = true
            floatingPanel.titleVisibility = .hidden
            floatingPanel.titlebarAppearsTransparent = true
            floatingPanel.isMovableByWindowBackground = true
            floatingPanel.level = .floating
         
         
            let mainWindow = NSApp.windows[0]
                mainWindow.delegate = self
          
        let apiView = APIView().edgesIgnoringSafeArea(.all).background(VisualEffects().edgesIgnoringSafeArea(.all))
        let contentView = ContentView(requ:Requester(), st: SpeechAndText()).edgesIgnoringSafeArea(.all)
            .background(VisualEffects().edgesIgnoringSafeArea(.all)
            )
      // Create the window and set the content view.
        
        if apiKey != "" {
            floatingPanel.contentView = NSHostingView(rootView: contentView)
        } else {
            floatingPanel.contentView = NSHostingView(rootView: apiView)
        }
        
        
            self.transcriptPermission()
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
            NSApp.hide(nil)
            return false
        }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    public func transcriptPermission() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self.permission = true
                    print("Speech recognition authorized")
                case .denied:
                    self.permission = false
                    print("Speech recognition authorization denied")
                case .restricted:
                    self.permission = false
                    print("Speech recognition authorization restricted")
                case .notDetermined:
                    self.permission = false
                    print("Speech recognition not determined")
                @unknown default:
                    self.permission = false
                    fatalError()
                }
            }
        }
    }
}
