import Foundation

struct SchemaField: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: FieldType
    var description: String
    var isOptional: Bool

    init(name: String, type: FieldType, description: String = "", isOptional: Bool = false) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.description = description
        self.isOptional = isOptional
    }

    enum FieldType: String, Codable, CaseIterable {
        case string = "String"
        case int = "Int"
        case double = "Double"
        case bool = "Bool"
        case stringArray = "[String]"
        case intArray = "[Int]"
    }
}

struct SchemaDefinition: Identifiable, Codable {
    let id: UUID
    var name: String
    var fields: [SchemaField]

    init(name: String, fields: [SchemaField]) {
        self.id = UUID()
        self.name = name
        self.fields = fields
    }

    // Generate Swift code for this schema
    var swiftCode: String {
        var lines: [String] = []
        lines.append("import FoundationModels")
        lines.append("")
        lines.append("@Generable")
        lines.append("struct \(name) {")
        for field in fields {
            let guideDesc = field.description.isEmpty ? field.name : field.description
            lines.append("    @Guide(description: \"\(guideDesc)\")")
            let typeStr = field.isOptional ? "\(field.type.rawValue)?" : field.type.rawValue
            lines.append("    var \(field.name): \(typeStr)")
            lines.append("")
        }
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    // Generate a prompt to ask the model to fill this schema
    func generationPrompt(context: String) -> String {
        var fieldDescs: [String] = []
        for field in fields {
            let optStr = field.isOptional ? " (optional)" : ""
            fieldDescs.append("- \(field.name): \(field.type.rawValue)\(optStr) — \(field.description)")
        }
        return """
        Generate a JSON object with the following fields:
        \(fieldDescs.joined(separator: "\n"))

        Context: \(context)

        Respond with ONLY valid JSON, no explanation.
        """
    }

    static let weatherExample = SchemaDefinition(
        name: "WeatherForecast",
        fields: [
            SchemaField(name: "city", type: .string, description: "City name"),
            SchemaField(name: "temperatureCelsius", type: .int, description: "Temperature in Celsius"),
            SchemaField(name: "condition", type: .string, description: "Weather condition (sunny, cloudy, rainy, etc.)"),
            SchemaField(name: "humidity", type: .int, description: "Humidity percentage 0-100"),
            SchemaField(name: "tags", type: .stringArray, description: "Relevant weather tags"),
        ]
    )
}
