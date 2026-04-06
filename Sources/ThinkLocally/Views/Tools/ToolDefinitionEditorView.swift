import SwiftUI

// MARK: - ToolDefinitionEditorView

/// Editor para una única ToolDefinition dentro del panel izquierdo.
struct ToolDefinitionEditorView: View {
    @Binding var definition: ToolDefinition

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Nombre
            VStack(alignment: .leading, spacing: 3) {
                Text("Name")
                    .roleLabelStyle()
                TextField("getWeather", text: $definition.name)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
            }

            // Descripción
            VStack(alignment: .leading, spacing: 3) {
                Text("Description")
                    .roleLabelStyle()
                TextField("What this tool does", text: $definition.description)
                    .textFieldStyle(.roundedBorder)
            }

            // Argumentos
            VStack(alignment: .leading, spacing: 3) {
                Text("Arguments")
                    .roleLabelStyle()
                TextField("city: String — The city name", text: $definition.argumentsDescription)
                    .textFieldStyle(.roundedBorder)
            }

            // Mock response
            VStack(alignment: .leading, spacing: 3) {
                Text("Mock Response")
                    .roleLabelStyle()
                TextEditor(text: $definition.mockResponse)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(Color(nsColor: .separatorColor), lineWidth: 1)
                    )
                    .frame(minHeight: 56)
            }
        }
        .padding(10)
        .background(Color(nsColor: .windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color(nsColor: .separatorColor), lineWidth: 1)
        )
    }
}
