//
//  APIView.swift
//  VoiceOpenAI
//
//
import SwiftUI


struct APIView: View {
    @AppStorage("apiKey") var apiKey = ""
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(0.5)
                .frame(width: 20)
                .scaledToFit()
            
            TextField("Paste the key here and restart the app", text: $apiKey)
                .disableAutocorrection(true)
                .textFieldStyle(.plain)
                .font(.system(size: 18))
                .frame(minWidth: 300)
                .help("Go to the OpenAI website, create a personal accout, add an copy a personal API key")
      

        }.padding([.top, .leading, .trailing], 20.0)
    }
}

