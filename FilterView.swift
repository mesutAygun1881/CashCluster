//
//  FilterView.swift
//  Cash Cluster
//
//  Created by Mesut Aygün on 22.05.2025.
//

import SwiftUI
import CoreData

struct FilterParameters {
    var selectedCategories: Set<String>
    var selectedParams: [String: Set<String>]
}

struct FilterView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [],
        animation: .default
    ) private var items: FetchedResults<ClusterItemEntity>
    
    @State private var customCategories: [CustomCategory] = []
    @State private var selectedCategories: Set<String> = []
    @State private var expandedCategory: String?
    @State private var selectedParams: [String: Set<String>] = [:] // [field: Set<value>]
    @State private var allCategories: [String] = []
    @State private var allParams: [String: [String: [String]]] = [:]
    @State private var isReady: Bool = false
    @State private var showFilteredSheet = false
    var onApply: ((FilterParameters) -> Void)? = nil

    private var filteredItems: [ClusterItemEntity] {
        items.filter { item in
            if !selectedCategories.isEmpty && !selectedCategories.contains(item.category ?? "") {
                return false
            }
            for (field, values) in selectedParams {
                if field == "Country", let country = item.country, !values.contains(country) { return false }
                if field == "Year", item.year != 0, !values.contains("\(item.year)") { return false }
                if field == "Collection", let collection = item.collection, !values.contains(collection) { return false }
                if let collection = item.collection,
                   let dict = try? JSONDecoder().decode([String: String].self, from: Data(collection.utf8)),
                   let val = dict[field], !values.contains(val) { return false }
            }
            return true
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("Choose filter parameters")
                .font(.title2).bold()
                .padding(.top, 24)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity, alignment: .center)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(allCategories, id: \.self) { category in
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Button(action: {
                                    if selectedCategories.contains(category) {
                                        selectedCategories.remove(category)
                                        if expandedCategory == category { expandedCategory = nil }
                                    } else {
                                        selectedCategories.insert(category)
                                        expandedCategory = category
                                    }
                                }) {
                                    Image(systemName: selectedCategories.contains(category) ? "checkmark.square" : "square")
                                        .foregroundColor(.blue)
                                    Text(category)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                                Spacer()
                                if selectedCategories.contains(category) {
                                    Button(action: {
                                        expandedCategory = expandedCategory == category ? nil : category
                                    }) {
                                        Image(systemName: expandedCategory == category ? "chevron.down" : "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            
                            if expandedCategory == category, let fields = allParams[category] {
                                ForEach(fields.keys.sorted(), id: \.self) { field in
                                    if let values = fields[field], !values.isEmpty {
                                        Text(field)
                                            .font(.subheadline).bold()
                                            .foregroundColor(.gray)
                                            .padding(.leading, 40)
                                            .padding(.top, 4)
                                        ForEach(values, id: \.self) { value in
                                            HStack {
                                                Button(action: {
                                                    var set = selectedParams[field, default: Set<String>()]
                                                    if set.contains(value) {
                                                        set.remove(value)
                                                    } else {
                                                        set.insert(value)
                                                    }
                                                    selectedParams[field] = set
                                                }) {
                                                    Image(systemName: selectedParams[field, default: Set<String>()].contains(value) ? "checkmark.square" : "square")
                                                        .foregroundColor(.blue)
                                                    Text(value)
                                                        .foregroundColor(.primary)
                                                }
                                                Spacer()
                                            }
                                            .padding(.leading, 60)
                                            .padding(.vertical, 2)
                                        }
                                    }
                                }
                            }
                        }
                        Divider()
                    }
                }
            }
           
            // --- Butonlar ---
            HStack {
                Button("Reset all filters") {
                    selectedCategories.removeAll()
                    selectedParams.removeAll()
                    expandedCategory = nil
                }
                .foregroundColor(.gray)
                Spacer()
                Button(action: {
                    // Filtrelenmiş itemları hesapla ve yeni sheet aç
                    showFilteredSheet = true
                }) {
                    Text("Apply filters")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 32)
                        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#1D3D98"), Color(hex: "#3A7BFF")]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .onAppear {
            loadCustomCategories()
            tryBuildParams()
            if let first = allCategories.first, selectedCategories.isEmpty {
                selectedCategories.insert(first)
                expandedCategory = first
            }
        }
        .onChange(of: customCategories) { _ in tryBuildParams() }
        .onChange(of: items.count) { _ in tryBuildParams() }
        .sheet(isPresented: $showFilteredSheet) {
            FilteredItemsView(items: filteredItems)
        }
    }
    
    private func loadCustomCategories() {
        if let data = UserDefaults.standard.data(forKey: "custom_categories"),
           let categories = try? JSONDecoder().decode([CustomCategory].self, from: data) {
            customCategories = categories
        }
    }
    
    private func tryBuildParams() {
        // Eğer veri geldiyse build et ve UI'ı göster
        if !customCategories.isEmpty || !items.isEmpty {
            buildCategoriesAndParams()
            isReady = true
        } else {
            isReady = false
        }
    }
    
    private func buildCategoriesAndParams() {
        // 1. Kategorileri oluştur
        var cats: [String] = ItemCategory.visibleCategories.map { $0.rawValue }
        cats.append(contentsOf: customCategories.map { $0.name })
        allCategories = cats
        // 2. Her kategori için alanları ve unique değerleri oluştur
        var result: [String: [String: [String]]] = [:]
        // Statik kategoriler
        for cat in ItemCategory.visibleCategories {
            let catName = cat.rawValue
            let catItems = items.filter { $0.category == catName }
            var fields: [String: Set<String>] = [:]
            // Alanlar her zaman gösterilsin (boş olsa bile)
            fields["Country"] = Set(catItems.compactMap { $0.country })
            fields["Year"] = Set(catItems.map { "\($0.year)" }.filter { $0 != "0" })
            fields["Collection"] = Set(catItems.compactMap { $0.collection })
            result[catName] = fields.mapValues { Array($0).sorted() }
        }
        // Custom kategoriler
        for custom in customCategories {
            let catItems = items.filter { $0.category == custom.name }
            var fields: [String: Set<String>] = [:]
            for field in custom.fields {
                let values = catItems.compactMap { item -> String? in
                    guard let json = item.collection,
                          let dict = try? JSONDecoder().decode([String: String].self, from: Data(json.utf8)) else { return nil }
                    return dict[field]
                }
                fields[field] = Set(values)
            }
            result[custom.name] = fields.mapValues { Array($0).sorted() }
        }
        allParams = result
        // Varsayılan olarak ilk kategori seçili ve açık olsun
        if let first = allCategories.first, selectedCategories.isEmpty {
            selectedCategories.insert(first)
            expandedCategory = first
        }
    }
}

struct FilteredItemsView: View {
    let items: [ClusterItemEntity]
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            ScrollView {
                if items.isEmpty {
                    Text("No items match the filter.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(items, id: \.self) { item in
                            VStack {
                                if let imageData = item.image1, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fill)
                                        .frame(height: 100)
                                        .clipped()
                                        .cornerRadius(10)
                                }
                                Text(item.name ?? "No Name")
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                            .padding(6)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Filtered Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
