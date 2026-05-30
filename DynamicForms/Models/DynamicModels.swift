//
//  Models.swift
//  DynamicForms
//
//

import Foundation
import SwiftUI

struct FormResponse: Codable {

    let theme: Theme
    let formTitle: String
    let fields: [Field]

    enum CodingKeys: String, CodingKey {
        case theme
        case formTitle = "form_title"
        case fields
    }

    init(
        theme: Theme = Theme(),
        formTitle: String = "",
        fields: [Field] = []
    ) {
        self.theme = theme
        self.formTitle = formTitle
        self.fields = fields
    }
}

struct Theme: Codable {

    let backgroundColor: String
    let textColor: String
    let borderColor: String
    let errorColor: String

    enum CodingKeys: String, CodingKey {
        case backgroundColor = "background_color"
        case textColor = "text_color"
        case borderColor = "border_color"
        case errorColor = "error_color"
    }

    init(
        backgroundColor: String = "#FFFFFF",
        textColor: String = "#000000",
        borderColor: String = "#CCCCCC",
        errorColor: String = "#FF0000"
    ) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.borderColor = borderColor
        self.errorColor = errorColor
    }
}
struct Field: Codable, Identifiable {
    
    let id: String
    let order: Int
    let type: FieldType
    let label: String
    let placeholder: String?
    let defaultValue: FieldValue?
    let maxLength: Int?
    let errorMessage: String?
    let required: Bool?
    let allowMultiple: Bool?
    let options: [Option]?
    let metadata: Metadata?
    let subtype: TextSubtype?
    let validation: Validation?

    enum CodingKeys: String, CodingKey {
        case id
        case order
        case type
        case subtype
        case label
        case placeholder
        case defaultValue = "default_value"
        case maxLength = "max_length"
        case errorMessage = "error_message"
        case required
        case allowMultiple = "allow_multiple"
        case options
        case metadata
        case validation
    }
}

enum FieldValue: Codable {
    case string(String)
    case bool(Bool)
    case int(Int)

    init(from decoder: Decoder) throws {

        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else {
            throw DecodingError.typeMismatch(
                FieldValue.self,
                .init(codingPath: decoder.codingPath,
                      debugDescription: "Unsupported type")
            )
        }
    }
}

enum FieldType: String, Codable {
    case text = "TEXT"
    case dropdown = "DROPDOWN"
    case checkbox = "CHECKBOX"
    case toggle = "TOGGLE"
    case colorPicker = "COLOR_PICKER"
}

struct Option: Codable, Identifiable {

    let id: String
    let label: String
}

struct Metadata: Codable {

    let links: [String: String]?
    let clickableTextColor: String?

    enum CodingKeys: String, CodingKey {
        case links
        case clickableTextColor = "clickable_text_color"
    }
}
enum TextSubtype: String, Codable {
    case plain = "PLAIN"
    case multiline = "MULTILINE"
    case number = "NUMBER"
    case url = "URL"
    case secure = "SECURE"
}

struct Validation: Codable {
    let maxLength: Int?
}
