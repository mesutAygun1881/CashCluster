import SwiftUI
import CoreData

//struct FilterParameters {
//    var selectedCategories: Set<String>
//    var selectedParams: [String: Set<String>]
//}

struct ClusterContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ClusterItemEntity.name, ascending: true)],
        animation: .default)
    private var items: FetchedResults<ClusterItemEntity>
    
    @State private var selectedTab: Tab = .coins
    @State private var showAddItemSheet = false
    @State private var showAddCategorySheet = false
    @State private var customCategories: [CustomCategory] = []
    @State private var selectedItem: ClusterItemEntity?
    @State private var showItemDetail = false
    
    var filterParams: FilterParameters? = nil
    
    enum Tab: Equatable {
        case coins, banknotes, custom(CustomCategory)
        
        var customCategory: CustomCategory? {
            if case .custom(let category) = self { return category }
            return nil
        }
    }
    
    var filteredItems: [ClusterItemEntity] {
        items.filter { item in
            // Eğer filterParams nil ise, mevcut sekmeye göre filtrele
            guard let filter = filterParams else {
                switch selectedTab {
                case .coins:
                    return item.category == ItemCategory.coin.rawValue
                case .banknotes:
                    return item.category == ItemCategory.banknote.rawValue
                case .custom(let category):
                    return item.category == category.name
                }
            }
            // Kategori filtresi
            guard filter.selectedCategories.contains(item.category ?? "") else { return false }
            // Parametreler (ör: Country, Year, Collection, custom fields)
            for (field, values) in filter.selectedParams {
                // Statik alanlar
                if field == "Country", let country = item.country, !values.contains(country) { return false }
                if field == "Year", item.year != 0, !values.contains("\(item.year)") { return false }
                if field == "Collection", let collection = item.collection, !values.contains(collection) { return false }
                // Custom alanlar
                if let collection = item.collection,
                   let dict = try? JSONDecoder().decode([String: String].self, from: Data(collection.utf8)),
                   let val = dict[field], !values.contains(val) { return false }
            }
            return true
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Üst başlık
                HStack {
                    Text("Cluster")
                        .font(.custom("Exo 2 ExtraBold", size: 28))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.top, 24)
                .padding(.horizontal, 20)

                // Tab bar (kategori barı)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Button(action: { selectedTab = .coins }) {
                            Text("Coins")
                                .fontWeight(.bold)
                                .foregroundColor(selectedTab == .coins ? .white : Color(hex: "#1D3D98"))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 24)
                                .background(selectedTab == .coins ? Color(hex: "#1D3D98") : Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(hex: "#1D3D98"), lineWidth: 2)
                                )
                        }
                        Button(action: { selectedTab = .banknotes }) {
                            Text("Banknotes")
                                .fontWeight(.bold)
                                .foregroundColor(selectedTab == .banknotes ? .white : Color(hex: "#1D3D98"))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 24)
                                .background(selectedTab == .banknotes ? Color(hex: "#1D3D98") : Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(hex: "#1D3D98"), lineWidth: 2)
                                )
                        }
                        ForEach(customCategories) { category in
                            Button(action: { selectedTab = .custom(category) }) {
                                Text(category.name)
                                    .fontWeight(.bold)
                                    .foregroundColor(selectedTab == .custom(category) ? .white : Color(hex: "#1D3D98"))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 24)
                                    .background(selectedTab == .custom(category) ? Color(hex: "#1D3D98") : Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(hex: "#1D3D98"), lineWidth: 2)
                                    )
                            }
                        }
                        // Mavi dolu yuvarlak + butonu
                        Button(action: { showAddCategorySheet = true }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color(hex: "#1D3D98"))
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(Color(hex: "#1D3D98"), lineWidth: 2)
                                )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                }

                // Item grid
                if filteredItems.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(Color(.systemGray3))
                        Text("There are no items in this section of your collection yet. They will appear here when you add them.")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 40)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(filteredItems) { item in
                                ItemCard(item: item, customCategory: selectedTab.customCategory)
                                    .onTapGesture {
                                        selectedItem = item
                                        showItemDetail = true
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                }
            }
            // Sağ altta kırmızı buton
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showAddItemSheet = true }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add new item")
                                .fontWeight(.bold)
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 22)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                        .shadow(radius: 6)
                    }
                    .padding(.bottom, 32)
                    .padding(.trailing, 24)
                }
            }
        }
        .sheet(isPresented: $showAddItemSheet) {
            if let custom = selectedTab.customCategory {
                AddItemSheetView(customCategory: custom)
            } else {
                AddItemSheetView(category: selectedTab == .coins ? .coin : .banknote)
            }
        }
        .sheet(isPresented: $showAddCategorySheet) {
            AddCategorySheetView { newCategory in
                customCategories.append(newCategory)
                saveCustomCategories()
            }
        }
        .sheet(isPresented: $showItemDetail) {
            if let item = selectedItem {
                ItemDetailSheetView(item: item)
            }
        }
        .onAppear {
            loadCustomCategories()
        }
    }
    
    private func loadCustomCategories() {
        if let data = UserDefaults.standard.data(forKey: "custom_categories"),
           let categories = try? JSONDecoder().decode([CustomCategory].self, from: data) {
            customCategories = categories
        }
    }
    
    private func saveCustomCategories() {
        if let data = try? JSONEncoder().encode(customCategories) {
            UserDefaults.standard.set(data, forKey: "custom_categories")
        }
    }
}

struct ItemCard: View {
    let item: ClusterItemEntity
    let customCategory: CustomCategory?
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let imageData = item.image1,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .frame(height: 160)
                    .clipped()
                    .cornerRadius(16)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray5))
                    .frame(height: 160)
            }
            // Overlay: Only Name
            VStack(alignment: .leading, spacing: 2) {
                if let customCategory = customCategory,
                   let collection = item.collection,
                   let data = collection.data(using: .utf8),
                   let dict = try? JSONDecoder().decode([String: String].self, from: data) {
                    if let name = dict.first(where: { $0.key.lowercased().contains("name") })?.value, !name.isEmpty {
                        Text(name)
                            .font(.headline)
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                    }
                } else {
                    if let name = item.name {
                        Text(name)
                            .font(.headline)
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                    }
                }
            }
            .padding(10)
            .background(Color.black.opacity(0.45))
            .cornerRadius(10)
            .padding([.leading, .bottom], 10)
        }
        .frame(height: 160)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.13), radius: 8, x: 0, y: 4)
    }
}

struct CustomCategory: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let fields: [String]
}

extension ClusterContentView.Tab {
    static func == (lhs: ClusterContentView.Tab, rhs: ClusterContentView.Tab) -> Bool {
        switch (lhs, rhs) {
        case (.coins, .coins), (.banknotes, .banknotes):
            return true
        case let (.custom(a), .custom(b)):
            return a.id == b.id
        default:
            return false
        }
    }
}

struct AddCategorySheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var categoryName = ""
    @State private var customFields: [String] = []
    @State private var newField: String = ""
    @State private var showAlert = false
    let onSave: (CustomCategory) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text("New Category")
                .font(.system(size: 20, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 24)
                .padding(.horizontal, 24)
            
            TextField("Category Name", text: $categoryName)
                .font(.system(size: 16))
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray3), lineWidth: 1))
                .background(Color(.systemGray6))
                .padding(.horizontal, 24)
                .padding(.top, 20)
            
            Text("Fields for items in this category")
                .font(.system(size: 16, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 8)
            VStack(spacing: 14) {
                // Sabit alanlar
                TextField("Name", text: .constant(""))
                    .font(.system(size: 16))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray3), lineWidth: 1))
                    .background(Color(.systemGray6))
                    .disabled(true)
                TextField("Year of foundation", text: .constant(""))
                    .font(.system(size: 16))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray3), lineWidth: 1))
                    .background(Color(.systemGray6))
                    .disabled(true)
                // Dinamik custom alanlar
                ForEach(customFields.indices, id: \.self) { idx in
                    HStack {
                        TextField("New element...", text: $customFields[idx])
                            .font(.system(size: 16))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 14)
                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray3), lineWidth: 1))
                            .background(Color(.systemGray6))
                        Button(action: { customFields.remove(at: idx) }) {
                            Image(systemName: "trash").foregroundColor(.red)
                        }
                        .padding(.trailing, 8)
                    }
                }
                // Yeni alan ekleme
                HStack {
                    TextField("New element...", text: $newField)
                        .font(.system(size: 16))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 14)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray3), lineWidth: 1))
                        .background(Color(.systemGray6))
                    Button(action: {
                        if !newField.trimmingCharacters(in: .whitespaces).isEmpty {
                            customFields.append(newField)
                            newField = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill").foregroundColor(.blue)
                    }
                    .padding(.trailing, 8)
                }
            }
            .padding(.horizontal, 24)
            Spacer()
            Button(action: {
                var allFields = customFields
                if !newField.trimmingCharacters(in: .whitespaces).isEmpty {
                    allFields.append(newField)
                }
                let category = CustomCategory(
                    id: UUID(),
                    name: categoryName,
                    fields: ["Name", "Year of foundation"] + allFields.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                )
                if categoryName.trimmingCharacters(in: .whitespaces).isEmpty {
                    showAlert = true
                    return
                }
                onSave(category)
                dismiss()
            }) {
                Text("Create Category")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#1D3D98"), Color(hex: "#3A7BFF")]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            Button(action: { dismiss() }) {
                Text("Cancel")
                    .foregroundColor(.gray)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.top, 8)
            }
            Spacer().frame(height: 18)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Category Name Required"),
                message: Text("Please enter a name for the category."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct ItemDetailSheetView: View {
    let item: ClusterItemEntity
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    @State private var editedName: String = ""
    @State private var editedYear: String = ""
    @State private var editedCountry: String = ""
    @State private var editedCollection: String = ""
    @State private var customFieldDict: [String: String] = [:]
    @State private var showDeleteAlert = false
    
    var images: [UIImage] {
        var result: [UIImage] = []
        if let image1 = item.image1, let uiImage = UIImage(data: image1) {
            result.append(uiImage)
        }
        if let image2 = item.image2, let uiImage = UIImage(data: image2) {
            result.append(uiImage)
        }
        if let image3 = item.image3, let uiImage = UIImage(data: image3) {
            result.append(uiImage)
        }
        return result
    }
    
    func decodeCustomFields() -> [String: String] {
        guard let collection = item.collection,
              let data = collection.data(using: .utf8),
              let dict = try? JSONDecoder().decode([String: String].self, from: data) else {
            return [:]
        }
        return dict
    }
    
    func encodeCustomFields(_ dict: [String: String]) -> String {
        guard let data = try? JSONEncoder().encode(dict),
              let string = String(data: data, encoding: .utf8) else {
            return ""
        }
        return string
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Images horizontal scroll
                if !images.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(images.indices, id: \.self) { idx in
                                Image(uiImage: images[idx])
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(width: 140, height: 140)
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                    }
                } else {
                    Spacer().frame(height: 24)
                }
                
                // Year, Name, Edit
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        if isEditing {
                            TextField("Year", text: $editedYear)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "#1D3D98"))
                                .keyboardType(.numberPad)
                        } else if item.year != 0 {
                            Text("\(item.year)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "#1D3D98"))
                        }
                        if isEditing {
                            TextField("Name", text: $editedName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                        } else if let name = item.name {
                            Text(name)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                    if !isEditing {
                        Button(action: {
                            isEditing = true
                            editedName = item.name ?? ""
                            editedYear = item.year != 0 ? String(item.year) : ""
                            editedCountry = item.country ?? ""
                            editedCollection = (decodeCustomFields().isEmpty ? (item.collection ?? "") : "")
                            customFieldDict = decodeCustomFields()
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(Color(hex: "#1D3D98"))
                                .padding(8)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Divider().padding(.vertical, 12)
                    .padding(.horizontal, 24)
                
                // Fields
                VStack(spacing: 16) {
                    // Country
                    HStack {
                        Text("Country")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                        if isEditing {
                            TextField("Country", text: $editedCountry)
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 140)
                        } else if let country = item.country, !country.isEmpty {
                            Text(country)
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 140, alignment: .trailing)
                        }
                    }
                    
                    // Collection
                    HStack {
                        Text("Collection")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                        if isEditing {
                            TextField("Collection", text: $editedCollection)
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 140)
                        } else if let collection = item.collection, !collection.isEmpty, (decodeCustomFields().isEmpty) {
                            Text(collection)
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 140, alignment: .trailing)
                        }
                    }
                    
                    // Custom fields (if any)
                    let customFields = decodeCustomFields()
                    ForEach(Array(customFields.keys.sorted()), id: \.self) { key in
                        HStack {
                            Text(key)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                            Spacer()
                            if isEditing {
                                TextField(key, text: Binding(
                                    get: { customFieldDict[key, default: customFields[key] ?? ""] },
                                    set: { customFieldDict[key] = $0 }
                                ))
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 140)
                            } else {
                                Text(customFields[key] ?? "")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 140, alignment: .trailing)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 4)
                
                // Delete button
                Button(action: { showDeleteAlert = true }) {
                    Text("Delete this item")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.top, 24)
                }
                
                // Back button
                Button(action: { 
                    if isEditing {
                        // Save edits
                        item.name = editedName
                        item.year = Int32(editedYear) ?? 0
                        item.country = editedCountry
                        item.collection = editedCollection
                        if !customFieldDict.isEmpty {
                            item.collection = encodeCustomFields(customFieldDict)
                        }
                        try? item.managedObjectContext?.save()
                        isEditing = false
                    } else {
                        dismiss()
                    }
                }) {
                    Text("Back")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color(hex: "#1D3D98"), Color(hex: "#3A7BFF")]), startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        .padding(.bottom, 24)
                }
            }
            .background(Color.white)
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete this item?"),
                message: Text("Are you sure you want to delete this item?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let moc = item.managedObjectContext {
                        moc.delete(item)
                        try? moc.save()
                    }
                    dismiss()
                },
                secondaryButton: .cancel()
            )
        }
    }
}






