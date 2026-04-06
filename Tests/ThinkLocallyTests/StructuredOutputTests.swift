import Foundation
import Testing
@testable import ThinkLocally

@Test func schemaExampleLoads() {
    let schema = SchemaDefinition.weatherExample
    #expect(schema.name == "WeatherForecast")
    #expect(schema.fields.count == 5)
}

@Test func schemaSwiftCodeGeneration() {
    let schema = SchemaDefinition.weatherExample
    let code = schema.swiftCode
    #expect(code.contains("@Generable"))
    #expect(code.contains("struct WeatherForecast"))
    #expect(code.contains("var city: String"))
    #expect(code.contains("import FoundationModels"))
}

@Test func schemaPromptGeneration() {
    let schema = SchemaDefinition.weatherExample
    let prompt = schema.generationPrompt(context: "Madrid today")
    #expect(prompt.contains("city"))
    #expect(prompt.contains("Madrid today"))
    #expect(prompt.contains("JSON"))
}

@Test func schemaRunResultValidation() {
    let valid = SchemaRunResult(
        rawContent: "{\"city\":\"Madrid\",\"temp\":22}",
        generationTime: 1.5,
        timestamp: Date()
    )
    #expect(valid.isValid)
    #expect(valid.formattedJSON.contains("Madrid"))

    let invalid = SchemaRunResult(
        rawContent: "not json",
        generationTime: 0.5,
        timestamp: Date()
    )
    #expect(!invalid.isValid)
}

@Test func schemaFieldTypes() {
    let allTypes = SchemaField.FieldType.allCases
    #expect(allTypes.count == 6)
    #expect(allTypes.contains(.string))
    #expect(allTypes.contains(.stringArray))
}
