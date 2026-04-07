import Testing
import Foundation
@testable import ThinkLocal

@Test func exportFormatFileExtensions() {
    #expect(ExportFormat.markdown.fileExtension == "md")
    #expect(ExportFormat.json.fileExtension == "json")
    #expect(ExportFormat.swift.fileExtension == "swift")
    #expect(ExportFormat.plainText.fileExtension == "txt")
}

@Test func exportFormatCoverage() {
    #expect(ExportFormat.allCases.count == 4)
}
