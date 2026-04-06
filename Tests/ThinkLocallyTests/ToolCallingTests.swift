import Testing
@testable import ThinkLocally

@Test func toolDefinitionExample() {
    let tool = ToolDefinition.weatherExample
    #expect(tool.name == "getWeather")
    #expect(!tool.description.isEmpty)
    #expect(!tool.mockResponse.isEmpty)
}

@Test func toolDefinitionCreation() {
    let tool = ToolDefinition(
        name: "test",
        description: "A test tool",
        argumentsDescription: "input: String",
        mockResponse: "result"
    )
    #expect(tool.name == "test")
    #expect(tool.mockResponse == "result")
}

@Test func toolDefinitionHasUniqueIDs() {
    let a = ToolDefinition(name: "a", description: "", argumentsDescription: "", mockResponse: "")
    let b = ToolDefinition(name: "b", description: "", argumentsDescription: "", mockResponse: "")
    #expect(a.id != b.id)
}

@Test func toolDefinitionDefaultsAreEmpty() {
    let tool = ToolDefinition()
    #expect(tool.name.isEmpty)
    #expect(tool.description.isEmpty)
    #expect(tool.argumentsDescription.isEmpty)
    #expect(tool.mockResponse.isEmpty)
}
