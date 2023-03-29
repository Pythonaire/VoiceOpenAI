//
//  ContentView.swift
//  VoiceOpenAI
//
//

import SwiftUI

struct CustomSpeakStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Button(action: {
                configuration.isOn.toggle()
            }, label: {
                Image(systemName: configuration.isOn ?
                        "mic.circle" : "mic.slash.circle")
                    .renderingMode(.template)
                    .foregroundColor(configuration.isOn ? .red : .accentColor)
                    .font(.system(size: 20))
            })
            .buttonStyle(PlainButtonStyle())
        }
    }
}
struct Progress: View {
    var body: some View {
        VStack {
            ProgressView()
            .scaleEffect(x: 0.5, y: 0.5, anchor: .center)
        }
    }
}

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var requ: Requester
    @StateObject private var st: SpeechAndText
    @State private var search: String = ""
    @State var questionAndAnswer : [QuestionAndAnswer] = []
    
    @State var didTapSpeech : Bool = false
    @State var tappedCopy : Bool = false
    @State var tappedUtterance : Bool = false
    
    @State private var contentAnswerHeight: CGFloat = 0.0
    
    private let pasteboard = NSPasteboard.general
    
    init(requ: Requester, st: SpeechAndText)
    {
        self._requ = StateObject(wrappedValue: requ)
        self._st = StateObject(wrappedValue: st)
    }
    func sessionType() {
        switch didTapSpeech {
        case true:
            try! st.startTranscription()
        case false:
            try! st.stopTranscription()
            Task {
                if !st.searchVoice.isEmpty {
                    await requ.performOpenAISearch(search: st.searchVoice)
                    questionAndAnswer = requ.questionAndAnswers
                    DispatchQueue.main.asyncAfter(deadline:.now() + 0.5) {
                        st.startUtterance(txtAnswer: requ.answer)
                    }
                }
            }
        }
    }
    private func stopUtterance() {
        tappedUtterance = true
        st.stopUtterance()
        DispatchQueue.main.asyncAfter(deadline:.now() + 1.5) {
            tappedUtterance = false
        }
    }
    private func copyToClipboard() {
        pasteboard.clearContents()
        pasteboard.setString(requ.answer, forType: .string)
        tappedCopy = true
        DispatchQueue.main.asyncAfter(deadline:.now() + 1.5) {
            tappedCopy = false
        }
    }
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(0.5)
                .frame(width: 20)
                .scaledToFit()
            TextField("Question here ...", text: $search)
                .textFieldStyle(.plain)
                .font(.system(size: 18))
                .frame(minWidth: 300)
                .help("write a request and get the text response")
                .onSubmit {
                    if !search.isEmpty {
                        Task {
                            await requ.performOpenAISearch(search: search)
                        }
                    }
                }
            if requ.searching { // is true while requesting underway
                Progress()
            }
            Toggle("", isOn: $didTapSpeech)
                .toggleStyle(CustomSpeakStyle())
                .help("Click here to send a speech request, get the resonse in text and speech")
                .onChange(of: didTapSpeech)  { _ in
                    sessionType()
                }
            Button { stopUtterance() }
        label: {
            Label("StopSpeaking", systemImage: "speaker.slash.circle")
                .foregroundColor(tappedUtterance ? .red : .gray)
                .labelStyle(.iconOnly)
                .help("Click here to stop the utterance")
                .font(.system(size: 20))
                }.buttonStyle(PlainButtonStyle())
            Button { copyToClipboard() }
        label: {
            Label("CopyToClipboard", systemImage: "doc.circle")
                .foregroundColor(tappedCopy ? .blue : .gray)
                .labelStyle(.iconOnly)
                .help("Click here for copy the answer to clipboard")
                .font(.system(size: 20))
                }.buttonStyle(PlainButtonStyle())
            
        }
        .padding([.top, .leading, .trailing], 20.0)
        
      
            
            //***********************
            
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    ForEach(requ.questionAndAnswers) { qa in
                        VStack(spacing: 0) {
                            Text(qa.question)
                                .bold()
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .padding([.top], 10)
                            Text(qa.answer)
                                .id(qa.id)
                                .padding(.bottom, 10)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                        .padding(.horizontal, 24.0)
                        .background(GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    DispatchQueue.main.async {
                                        contentAnswerHeight =  proxy.size.height
                                    }
                                }
                        })
                    }
                    .onChange(of: requ.questionAndAnswers.count) { _ in
                        DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                            if let floatingPanel = NSApplication.shared.windows.first {
                                let contentRect = NSRect(x: 0, y: 0, width: 800, height: contentAnswerHeight + 75)
                                floatingPanel.setContentSize(contentRect.size)
                            }
                        }
                        if let last = requ.questionAndAnswers.last {
                            withAnimation {
                                proxy.scrollTo(last.id)
                            }
                        }
                    }
                }
            }
            //************************************
      
        
    }
    }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(requ: Requester(), st: SpeechAndText())
    }
}
