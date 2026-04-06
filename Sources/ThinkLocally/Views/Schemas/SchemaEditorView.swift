import SwiftUI

struct SchemaEditorView: View {
    @Binding var schema: SchemaDefinition

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Struct name
            HStack {
                Text("@Generable struct")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                TextField("Name", text: $schema.name)
                    .font(.system(.body, design: .monospaced).weight(.semibold))
                    .textFieldStyle(.plain)
            }

            Divider()

            // Fields
            ForEach($schema.fields) { $field in
                SchemaFieldRow(field: $field, onDelete: {
                    schema.fields.removeAll(where: { $0.id == field.id })
                })
            }

            // Add field button
            Button {
                schema.fields.append(SchemaField(name: "newField", type: .string))
            } label: {
                Label("Add Field", systemImage: "plus")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
        }
        .padding(12)
    }
}

struct SchemaFieldRow: View {
    @Binding var field: SchemaField
    let onDelete: () -> Void
    @State private var isHovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                // Field name
                TextField("name", text: $field.name)
                    .font(.system(.body, design: .monospaced))
                    .textFieldStyle(.plain)
                    .frame(maxWidth: 150)

                Text(":")
                    .foregroundStyle(.secondary)

                // Type picker
                Picker("", selection: $field.type) {
                    ForEach(SchemaField.FieldType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .labelsHidden()
                .frame(width: 100)

                // Optional toggle
                Toggle("?", isOn: $field.isOptional)
                    .toggleStyle(.checkbox)
                    .font(.system(.caption, design: .monospaced))

                Spacer()

                if isHovering {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.borderless)
                }
            }

            // Description (Guide hint)
            HStack(spacing: 4) {
                Text("@Guide")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.tertiary)
                TextField("description", text: $field.description)
                    .font(.system(.caption, design: .monospaced))
                    .textFieldStyle(.plain)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(isHovering ? Color.amberGold.opacity(0.05) : .clear, in: .rect(cornerRadius: 4))
        .onHover { isHovering = $0 }
    }
}
