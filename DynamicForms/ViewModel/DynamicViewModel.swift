//
//  DynamicViewModel.swift
//  DynamicForms
//
//

import Foundation
import Combine

final class DynamicViewModel: ObservableObject {

    @Published var form = FormResponse()

    init() {
        loadJson()
    }

    func loadJson() {
        print(Bundle.main.bundlePath)
        print(Bundle.main.paths(forResourcesOfType: "json", inDirectory: nil))
        guard let url = Bundle.main.url(
            forResource: "FormJson",
            withExtension: "json"
        ) else {

            print("JSON file not found")
            return
        }

        do {

            let data = try Data(contentsOf: url)

            let response = try JSONDecoder()
                .decode(FormResponse.self, from: data)

            DispatchQueue.main.async {
                self.form = response
            }

        } catch {

            print("Decoding Error:", error)
        }
    }
}
