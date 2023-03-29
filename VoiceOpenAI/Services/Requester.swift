//
//  Requester.swift
//  VoiceOpenAI
//
//

import SwiftUI

@MainActor
class Requester: ObservableObject {
    @Published var answer: String = ""
    @Published var success: Bool = false
    @Published var failureMessage: String = "Failure in connecting to OpenAI"
    @Published var questionAndAnswers: [QuestionAndAnswer] = []
    @Published var searching: Bool = false

    func populateAnswer(search: String) async {
        do {
            let answer = try await Webservice().sendQuestion(url: OpenAIRequest.ChatGPTUrl, search: search)
                self.answer = answer.choices[0].text
                self.success = true
        } catch {
            self.success = false
            print(error)
        }
    }
    func performOpenAISearch (search: String) async {
        self.searching = true
        let _: () =  await self.populateAnswer(search: search)
        switch self.success {
        case true:
            let questionAndAnswer = QuestionAndAnswer(question: search, answer: self.answer)
            self.questionAndAnswers.append(questionAndAnswer)
            self.searching = false
        case false:
            print(self.failureMessage)
            self.searching = false
        }
    }
}
struct OpenAIRequest {
        static let ChatGPTUrl = URL(string: "https://api.openai.com/v1/completions")!
        static let max_tokens: Int = 512 // count of words in the answer
        static let modelName = "text-davinci-003"
        static let presence_penalty: Int = 1
        static let frequency_penalty: Int = 1
        static let bestof: Int = 1
        static let top_p: Double = 0.5
        static let temperature: Double = 0.9 // intensity of the answer
        static let n: Int = 1 // count of section in the answer
}

struct OpenAIResponse: Codable {
    let choices: [Choice]
    struct Choice: Codable {
        let text: String
    }
}
struct QuestionAndAnswer: Identifiable {
    let id = UUID()
    let question: String
    var answer: String
}

