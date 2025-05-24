//import SwiftUI
//
//struct CustomCategory: Identifiable, Codable, Equatable {
//    let id: UUID
//    var name: String
//    var fields: [String]
//    init(name: String, fields: [String]) {
//        self.id = UUID()
//        self.name = name
//        self.fields = fields
//    }
//}
//
//struct AddCategorySheetView: View {
//    @Environment(\.dismiss) private var dismiss
//    @State private var categoryName: String = ""
//    @State private var customFields: [String] = []
//    @State private var newField: String = ""
//    var onSave: (CustomCategory) -> Void
//
//    var body: some View {
//        VStack(spacing: 0) {
//            Text("New Collection")
//                .font(.system(size: 20, weight: .bold))
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.top, 24)
//                .padding(.horizontal, 24)
//            TextField("*Category name", text: $categoryName)
//                .font(.system(size: 16))
//                .padding(.vertical, 12)
//                .padding(.horizontal, 14)
//                .background(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray3), lineWidth: 1))
//                .background(Color(.systemGray6))
//                .padding(.horizontal, 24)
//                .padding(.bottom, 16)
//            Text("Collection elements for items")
//                .font(.system(size: 16, weight: .medium))
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal, 24)
//                .padding(.bottom, 8)
//            VStack(spacing: 14) {
//                TextField("Name", text: .constant(""))
//                    .font(.system(size: 16))
//                    .padding(.vertical, 12)
//                    .padding(.horizontal, 14)
//                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray3), lineWidth: 1))
//                    .background(Color(.systemGray6))
//                    .disabled(true)
//                TextField("Year of foundation", text: .constant(""))
//                    .font(.system(size: 16))
//                    .padding(.vertical, 12)
//                    .padding(.horizontal, 14)
//                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray3), lineWidth: 1))
//                    .background(Color(.systemGray6))
//                    .disabled(true)
//                ForEach(customFields.indices, id: \.self) { idx in
//                    HStack {
//                        TextField("New element...", text: $customFields[idx])
//                            .font(.system(size: 16))
//                            .padding(.vertical, 12)
//                            .padding(.horizontal, 14)
//                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray3), lineWidth: 1))
//                            .background(Color(.systemGray6))
//                        Button(action: { customFields.remove(at: idx) }) {
//                            Image(systemName: "trash").foregroundColor(.red)
//                        }
//                        .padding(.trailing, 8)
//                    }
//                }
//                HStack {
//                    TextField("New element...", text: $newField)
//                        .font(.system(size: 16))
//                        .padding(.vertical, 12)
//                        .padding(.horizontal, 14)
//                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray3), lineWidth: 1))
//                        .background(Color(.systemGray6))
//                    Button(action: {
//                        if !newField.trimmingCharacters(in: .whitespaces).isEmpty {
//                            customFields.append(newField)
//                            newField = ""
//                        }
//                    }) {
//                        Image(systemName: "plus.circle.fill").foregroundColor(.blue)
//                    }
//                    .padding(.trailing, 8)
//                }
//            }
//            .padding(.horizontal, 24)
//            Spacer()
//            Button(action: {
//                var allFields = customFields
//                if !newField.trimmingCharacters(in: .whitespaces).isEmpty {
//                    allFields.append(newField)
//                }
//                let category = CustomCategory(
//                    name: categoryName,
//                    fields: ["Name", "Year of foundation"] + allFields
//                )
//                onSave(category)
//                dismiss()
//            }) {
//                Text("Save new category")
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 16)
//                    .background(Color.blue.opacity(0.5))
//                    .cornerRadius(12)
//            }
//            .padding(.horizontal, 24)
//            .padding(.top, 12)
//            .disabled(categoryName.trimmingCharacters(in: .whitespaces).isEmpty)
//            Button(action: { dismiss() }) {
//                Text("Cancel, back")
//                    .foregroundColor(.gray)
//                    .font(.system(size: 16, weight: .medium))
//                    .padding(.top, 8)
//            }
//            Spacer().frame(height: 18)
//        }
//    }
//} 
