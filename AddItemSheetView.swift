import SwiftUI
import PhotosUI
import CoreData

enum ItemCategory: String, CaseIterable, Codable {
    case coin = "Coin"
    case banknote = "Banknote"
    case other = "Other"

    static var visibleCategories: [ItemCategory] {
        return [.coin, .banknote] // ileride yeni kategoriler eklenebilir
    }
}

struct AddItemSheetView: View {
    let category: ItemCategory?
    let customCategory: CustomCategory?
    @Environment(\.dismiss) private var dismiss
    @State private var pickerItems: [PhotosPickerItem?] = [nil, nil, nil]
    @State private var images: [UIImage?] = [nil, nil, nil]
    @State private var showPickers: [Bool] = [false, false, false]
    @State private var name: String = ""
    @State private var color: String = ""
    @State private var showAlert = false
    @State private var selectedYear: Int? = nil
    @State private var showYearPicker = false
    @State private var country: String = ""
    @State private var collection: String = ""
    // For custom fields
    @State private var customFieldValues: [String] = []
    let years: [Int] = Array(1900...Calendar.current.component(.year, from: Date())).reversed()
    
    init(category: ItemCategory) {
        self.category = category
        self.customCategory = nil
    }
    init(customCategory: CustomCategory) {
        self.category = nil
        self.customCategory = customCategory
        _customFieldValues = State(initialValue: Array(repeating: "", count: customCategory.fields.count))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("New item")
                .font(.system(size: 20, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 24)
                .padding(.horizontal, 24)
            
            HStack(spacing: 16) {
                ForEach(0..<3) { idx in
                    PhotoPickerView(
                        image: $images[idx],
                        pickerItem: $pickerItems[idx],
                        showPicker: $showPickers[idx]
                    )
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 20)
            .padding(.horizontal, 24)
            
            Text("Collection elements for items")
                .font(.system(size: 16, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
            
            VStack(spacing: 14) {
                if let category = category {
                    TextField("*Name", text: $name)
                        .font(.system(size: 16))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 14)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray3), lineWidth: 1))
                        .background(Color(.systemGray6))
                    Button(action: { showYearPicker = true }) {
                        HStack {
                            Text(selectedYear != nil ? String(selectedYear!) : "Year")
                                .foregroundColor(selectedYear == nil ? .gray : .primary)
                                .font(.system(size: 16))
                            Spacer()
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 14)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray3), lineWidth: 1))
                        .background(Color(.systemGray6))
                    }
                    .confirmationDialog("Select Year", isPresented: $showYearPicker, titleVisibility: .visible) {
                        ForEach(years, id: \.self) { year in
                            Button(String(year)) { selectedYear = year }
                        }
                    }
                    if category == .coin || category == .banknote {
                        TextField("Country", text: $country)
                            .font(.system(size: 16))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 14)
                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray3), lineWidth: 1))
                            .background(Color(.systemGray6))
                        TextField("Collection", text: $collection)
                            .font(.system(size: 16))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 14)
                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray3), lineWidth: 1))
                            .background(Color(.systemGray6))
                    }
                    if category == .other {
                        TextField("Color", text: $color)
                            .font(.system(size: 16))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 14)
                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray3), lineWidth: 1))
                            .background(Color(.systemGray6))
                    }
                } else if let customCategory = customCategory {
                    ForEach(customCategory.fields.indices, id: \ .self) { idx in
                        let field = customCategory.fields[idx]
                        if field.lowercased().contains("name") {
                            TextField("*Name", text: Binding(
                                get: { customFieldValues.indices.contains(idx) ? customFieldValues[idx] : "" },
                                set: { customFieldValues.indices.contains(idx) ? (customFieldValues[idx] = $0) : customFieldValues.append($0) }
                            ))
                                .font(.system(size: 16))
                                .padding(.vertical, 12)
                                .padding(.horizontal, 14)
                                .background(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray3), lineWidth: 1))
                                .background(Color(.systemGray6))
                        } else if field.lowercased().contains("year") {
                            Button(action: { showYearPicker = true }) {
                                HStack {
                                    Text(selectedYear != nil ? String(selectedYear!) : field)
                                        .foregroundColor(selectedYear == nil ? .gray : .primary)
                                        .font(.system(size: 16))
                                    Spacer()
                                    Image(systemName: "calendar")
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 14)
                                .background(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray3), lineWidth: 1))
                                .background(Color(.systemGray6))
                            }
                            .confirmationDialog("Select Year", isPresented: $showYearPicker, titleVisibility: .visible) {
                                ForEach(years, id: \.self) { year in
                                    Button(String(year)) { selectedYear = year }
                                }
                            }
                        } else {
                            TextField(field, text: Binding(
                                get: { customFieldValues.indices.contains(idx) ? customFieldValues[idx] : "" },
                                set: { customFieldValues.indices.contains(idx) ? (customFieldValues[idx] = $0) : customFieldValues.append($0) }
                            ))
                                .font(.system(size: 16))
                                .padding(.vertical, 12)
                                .padding(.horizontal, 14)
                                .background(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray3), lineWidth: 1))
                                .background(Color(.systemGray6))
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            Spacer()
            Button(action: {
                if let category = category {
                    if name.trimmingCharacters(in: .whitespaces).isEmpty {
                        showAlert = true
                        return
                    }
                } else if let customCategory = customCategory {
                    if customFieldValues.first?.trimmingCharacters(in: .whitespaces).isEmpty ?? true {
                        showAlert = true
                        return
                    }
                }
                saveItemToCoreData()
                dismiss()
            }) {
                Text("Add new item")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.6, green: 0.75, blue: 1.0), Color(red: 0.2, green: 0.4, blue: 0.9)]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            Button(action: { dismiss() }) {
                Text("Cancel, back")
                    .foregroundColor(.gray)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.top, 8)
            }
            Spacer().frame(height: 18)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Name is required"), message: Text("Please enter a name for the item."), dismissButton: .default(Text("OK")))
        }
    }
    
    func saveItemToCoreData() {
        let context = CoreDataManager.shared.context
        let newItem = ClusterItemEntity(context: context)
        if let category = category {
            newItem.name = name
            newItem.year = selectedYear != nil ? Int32(selectedYear!) : 0
            newItem.color = category == .other ? color : nil
            newItem.category = category.rawValue
            newItem.country = (category == .coin || category == .banknote) ? country : nil
            newItem.collection = (category == .coin || category == .banknote) ? collection : nil
        } else if let customCategory = customCategory {
            // Save all custom fields as JSON string in collection
            newItem.name = customFieldValues.first ?? ""
            newItem.year = selectedYear != nil ? Int32(selectedYear!) : 0
            newItem.color = nil
            newItem.category = customCategory.name
            newItem.country = nil
            let dict = Dictionary(uniqueKeysWithValues: zip(customCategory.fields, customFieldValues))
            if let jsonData = try? JSONEncoder().encode(dict), let jsonString = String(data: jsonData, encoding: .utf8) {
                newItem.collection = jsonString
            } else {
                newItem.collection = nil
            }
        }
        newItem.image1 = images.indices.contains(0) ? images[0]?.jpegData(compressionQuality: 0.8) : nil
        newItem.image2 = images.indices.contains(1) ? images[1]?.jpegData(compressionQuality: 0.8) : nil
        newItem.image3 = images.indices.contains(2) ? images[2]?.jpegData(compressionQuality: 0.8) : nil
        print("[CoreData] Kaydetme başlıyor...")
        print("[CoreData] name: \(newItem.name ?? "") category: \(newItem.category ?? "") collection: \(newItem.collection ?? "")")
        let imageCount = images.filter { $0 != nil }.count
        print("[CoreData] image count: \(imageCount)")
        do {
            try context.save()
            print("[CoreData] Başarıyla kaydedildi!")
        } catch {
            print("[CoreData] HATA: Kaydedilemedi - \(error)")
        }
    }
}

struct PhotoPickerView: View {
    @Binding var image: UIImage?
    @Binding var pickerItem: PhotosPickerItem?
    @Binding var showPicker: Bool
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray4))
                .frame(width: 80, height: 80)
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                VStack {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
            }
        }
        .onTapGesture { showPicker = true }
        .photosPicker(
            isPresented: $showPicker,
            selection: $pickerItem,
            matching: .images
        )
        .onChange(of: pickerItem) { newValue in
            if let item = newValue {
                item.loadTransferable(type: Data.self) { result in
                    if case .success(let data) = result, let data, let uiImage = UIImage(data: data) {
                        image = uiImage
                    }
                }
            }
        }
    }
}

struct ClusterItem: Codable {
    let images: [Data] // JPEG data
    let name: String
    let year: Int
    let color: String
    let category: String
    let country: String
    let collection: String
    
    static func loadAll() -> [ClusterItem] {
        if let data = UserDefaults.standard.data(forKey: "cluster_items"),
           let items = try? JSONDecoder().decode([ClusterItem].self, from: data) {
            return items
        }
        return []
    }
    static func saveAll(_ items: [ClusterItem]) {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: "cluster_items")
        }
    }
} 
