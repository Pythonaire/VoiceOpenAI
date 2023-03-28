//
//  WebService.swift
//  VoiceOpenAI
//
//  Created by Peter Wiechmann on 16.03.23.
//
import SwiftUI

enum NetworkError: Error {
    case invalidResponse
}

class Webservice {
    @AppStorage("apiKey") var apiKey = ""
    @State var detectLanguage: String = "de"
   
    func sendQuestion(url:URL, search: String) async throws -> OpenAIResponse
    {
        let apiString = "Bearer " + apiKey
        let parameters = [
            "model": OpenAIRequest.modelName,
            "prompt" : search,
            "max_tokens": OpenAIRequest.max_tokens,
            "presence_penalty": OpenAIRequest.presence_penalty,
            "frequency_penalty": OpenAIRequest.frequency_penalty,
            "best_of": OpenAIRequest.bestof,
            "top_p": OpenAIRequest.top_p,
            "temperature": OpenAIRequest.temperature
        ] as [String : Any]
        
        var request = URLRequest(url: OpenAIRequest.ChatGPTUrl)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiString, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        let requestBody =  try! JSONSerialization.data(withJSONObject: parameters)
        request.httpBody = requestBody
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        return try JSONDecoder().decode(OpenAIResponse.self, from: data)
    }
}

