import SwiftUI
import MapKit
import CoreLocation

// MARK: - App Info
// Ithacaround
// A personalized discovery app for Cornell students
// Created for Ithaca, NY local recommendations

// MARK: - Data Models
struct Location: Identifiable, Codable {
    var id = UUID()
    let name: String
    let category: LocationCategory
    let cuisineTypes: [CuisineType]
    let priceRange: PriceRange // , $, $$$
    let latitude: Double
    let longitude: Double
    let atmosphere: [AtmosphereType]
    let features: [Feature]
    let hours: String
    let description: String
    let address: String
    let rating: Double
    let reviewCount: Int
    let imageURL: String?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

enum LocationCategory: String, CaseIterable, Codable {
    case restaurant = "Restaurant"
    case cafe = "Cafe"
    case bar = "Bar"
    case studySpot = "Study Spot"
    case outdoor = "Outdoor"
    case entertainment = "Entertainment"
    
    var icon: String {
        switch self {
        case .restaurant: return "fork.knife"
        case .cafe: return "cup.and.saucer"
        case .bar: return "wineglass"
        case .studySpot: return "book"
        case .outdoor: return "leaf"
        case .entertainment: return "theatermasks"
        }
    }
}

enum CuisineType: String, CaseIterable, Codable {
    case american = "American"
    case italian = "Italian"
    case asian = "Asian"
    case mexican = "Mexican"
    case indian = "Indian"
    case mediterranean = "Mediterranean"
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case pizza = "Pizza"
    case coffee = "Coffee"
    case dessert = "Dessert"
    case thai = "Thai"
    case chinese = "Chinese"
    case japanese = "Japanese"
}

enum PriceRange: String, CaseIterable, Codable {
    case budget = "$"
    case moderate = "$$"
    case expensive = "$$$"
    
    var description: String {
        switch self {
        case .budget: return "Under $15"
        case .moderate: return "$15-25"
        case .expensive: return "$25+"
        }
    }
}

enum AtmosphereType: String, CaseIterable, Codable {
    case casual = "Casual"
    case upscale = "Upscale"
    case romantic = "Romantic"
    case studyFriendly = "Study Friendly"
    case lively = "Lively"
    case quiet = "Quiet"
    case familyFriendly = "Family Friendly"
    case nature = "Nature"
}

enum Feature: String, CaseIterable, Codable {
    case wifi = "WiFi"
    case outdoorSeating = "Outdoor Seating"
    case lateNight = "Late Night"
    case delivery = "Delivery"
    case parking = "Parking"
    case wheelchairAccessible = "Wheelchair Accessible"
    case groupFriendly = "Group Friendly"
    case dateSpot = "Date Spot"
}

struct UserPreferences: Codable {
    var favoriteCuisines: Set<CuisineType> = []
    var preferredPriceRanges: Set<PriceRange> = [.budget, .moderate]
    var preferredAtmospheres: Set<AtmosphereType> = []
    var importantFeatures: Set<Feature> = []
    var dietaryRestrictions: Set<CuisineType> = []
    var maxDistance: Double = 5.0 // miles
}



// MARK: - View Models
class LocationService: ObservableObject {
    @Published var locations: [Location] = []
    @Published var userPreferences = UserPreferences()
    @Published var favoriteLocations: Set<UUID> = []
    
    init() {
        loadSampleData()
        loadUserPreferences()
    }
    
    func loadSampleData() {
        locations = [
            Location(
                name: "Collegetown Bagels",
                category: .cafe,
                cuisineTypes: [.american, .coffee],
                priceRange: .budget,
                latitude: 42.4440,
                longitude: -76.4830,
                atmosphere: [.casual, .studyFriendly],
                features: [.wifi, .delivery],
                hours: "6.00 AM - 12:00 PM",
                description: "classic bagel shop beloved by Cornell students. Great for breakfase, late-night snacks, coffee chats, and study sessions.",
                address: "420 College Ave, Ithaca, NY 14850",
                rating: 4.3,
                reviewCount: 1308,
                imageURL: nil
            ),
            Location (
                name: "Moosewood Restaurant",
                category: .restaurant,
                cuisineTypes: [.vegetarian, .vegan, .american],
                priceRange: .moderate,
                latitude: 42.2629,
                longitude: -76.2956,
                atmosphere: [.casual, .familyFriendly],
                features: [.wheelchairAccessible, .groupFriendly],
                hours: "11:30 AM - 3:00 PM, 5:00 PM - 9:00 PM",
                description: "Famous vegetarian restaurant with creative, internationally-inspired dishes.",
                address: "215 N Cayuga St, Ithaca, NY 14850",
                rating: 4.4,
                reviewCount: 189,
                imageURL: nil
            ),
            Location (
                name: "The Rook",
                category: .bar,
                cuisineTypes: [.american],
                priceRange: .expensive,
                latitude: 42.4427,
                longitude: -76.4998,
                atmosphere: [.lively, .casual],
                features: [.groupFriendly],
                hours: "4:00 PM - 9:00 PM",
                description: "Popular student hangout with great burgers and a lively atmosphere.",
                address: "105 W Court St Suite 100, Ithaca, NY 14850",
                rating: 4.4,
                reviewCount: 445,
                imageURL: nil
            ),
            Location (
                name: "Ithaca Falls",
                category: .outdoor,
                cuisineTypes: [],
                priceRange: .budget,
                latitude: 42.4532,
                longitude: -76.4915,
                atmosphere: [.quiet, .nature],
                features: [.parking],
                hours: "Dawn - Dusk",
                description: "Beautiful waterfall and swimming hole, perfect for outdoor enthusiasts.",
                address: "Downtown Ithaca, near Stewart Park, where Fall Creek intersects the glacial trough of Cayuga Lake",
                rating: 4.7,
                reviewCount: 279,
                imageURL: nil
            ),
            Location(
                name: "Gorgers Subs",
                category: .restaurant,
                cuisineTypes: [.american],
                priceRange: .budget,
                latitude: 42.4398,
                longitude: -76.4996,
                atmosphere: [.casual],
                features: [.delivery],
                hours: "11:00 AM - 8:00 PM",
                description: "Art-lined counter serve known for its variety of large, internationally inspired sub sandwiches.",
                address: "116 W State St, Ithaca, NY 14850",
                rating: 4.6,
                reviewCount: 554,
                imageURL: nil
            ),
            Location (
                name: "Mercato Bar & Kitchen",
                category: .restaurant,
                cuisineTypes: [.italian, .american],
                priceRange: .expensive,
                latitude: 42.4400,
                longitude: -76.4958,
                atmosphere: [.upscale, .romantic],
                features: [.dateSpot, .wheelchairAccessible],
                hours: "5:30 PM - 9:00 PM",
                description: "Chef-owned eatery serving seasonal Italian food in a cozy space with a full bar & craft cocktails.",
                address: "108 N Aurora St, Ithaca, NY 14850",
                rating: 4.4,
                reviewCount: 220,
                imageURL: nil
            )
        ]
    }
    
    func getRecommendations() -> [Location] {
        let scored = locations.map { location in
            (location, calculateScore(for: location))
        }
        
        return scored
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
    }
    
    private func calculateScore(for location: Location) -> Double {
        var score = 0.0
        
        // Cuisine preference match (40%)
        let cuisineMatch = location.cuisineTypes.contains { userPreferences.favoriteCuisines.contains($0) }
        if cuisineMatch { score += 0.4 }
        
        // Price range match (25%)
        if userPreferences.preferredPriceRanges.contains(location.priceRange) {
            score += 0.25
        }
        
        // Atmosphere match (20%)
        let atmosphereMatch = location.atmosphere.contains { userPreferences.preferredAtmospheres.contains($0) }
        if atmosphereMatch { score += 0.2 }
        
        // Feature match (15%)
        let featureMatch = location.features.contains { userPreferences.importantFeatures.contains($0) }
        if featureMatch { score += 0.15 }
        
        // Rating boost
        score += (location.rating / 5.0) * 0.1
        
        return score
    }
    
    func toggleFavorite(_ location: Location) {
        if favoriteLocations.contains(location.id) {
            favoriteLocations.remove(location.id)
        } else {
            favoriteLocations.insert(location.id)
        }
        saveFavorites()
    }
    
    func isFavorite(_ location: Location) -> Bool {
        favoriteLocations.contains(location.id)
    }
    
    private func loadUserPreferences() {
        if let data = UserDefaults.standard.data(forKey: "userPreferences"),
           let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            self.userPreferences = preferences
        }
        
        if let favoritesData = UserDefaults.standard.data(forKey: "favoriteLocations"),
           let favorites = try? JSONDecoder().decode(Set<UUID>.self, from: favoritesData) {
            self.favoriteLocations = favorites
        }
    }
    
    func saveUserPreferences() {
        if let data = try? JSONEncoder().encode(userPreferences) {
            UserDefaults.standard.set(data, forKey: "userPreferences")
        }
    }
    
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteLocations) {
            UserDefaults.standard.set(data, forKey: "favoriteLocations")
        }
    }
    
    func searchLocations(query: String, category: LocationCategory? = nil) -> [Location] {
        var filteredLocations = locations
        
        if let category = category {
            filteredLocations = filteredLocations.filter { $0.category == category }
        }
        
        if !query.isEmpty {
            filteredLocations = filteredLocations.filter { location in
                location.name.localizedCaseInsensitiveContains(query) ||
                location.description.localizedCaseInsensitiveContains(query) ||
                location.cuisineTypes.contains { $0.rawValue.localizedCaseInsensitiveContains(query) }
            }
        }
        
        return filteredLocations
    }
}

// MARK: - Views
struct ContentView: View {
    @StateObject private var locationService = LocationService()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RecommendationsView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("For You")
                }
                .tag(0)
            
            ExploreView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Explore")
                }
                .tag(1)
            
            MapView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
                .tag(2)
            
            FavoritesView()
                .tabItem {
                    Image(systemName: "bookmark.fill")
                    Text("Favorites")
                }
                .tag(3)
            
//            SettingsView()
//                .tabItem {
//                    Image(systemName: "gearshape.fill")
//                    Text("Settings")
//                }
//                .tag(4)
        }
        .environmentObject(locationService)
        .accentColor(.red)
    }
}

struct RecommendationsView: View {
    @EnvironmentObject var locationService: LocationService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {   // Vertically stacking
                    HeaderView()        // Welcome message at top
                    
                    LazyVStack(spacing: 16) { // only creates views as needed for performance
                        ForEach(locationService.getRecommendations().prefix(10)) { location in // takes first 10 items only
                            NavigationLink(destination: LocationDetailView(location: location)) { // pushes to a detail screen
                                LocationCardView(location: location)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("For You")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct HeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome to Cornell!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Discover the best spots around Ithaca, tailored just for you")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct LocationCardView: View {
    let location: Location
    @EnvironmentObject var locationService: LocationService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(location.category.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    locationService.toggleFavorite(location)
                }) {
                    Image(systemName: locationService.isFavorite(location) ? "heart.fill" : "heart")
                        .foregroundColor(locationService.isFavorite(location) ? .red : .gray)
                        .font(.title3)
                }
            }
            
            HStack {
                Image(systemName: location.category.icon)
                    .foregroundColor(.red)
                
                Text(location.cuisineTypes.map { $0.rawValue }.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(location.priceRange.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            }
            
            HStack {
                HStack(spacing: 2) {
                    ForEach(0..<5) { i in
                        Image(systemName: i < Int(location.rating) ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
                
                Text("\(location.rating, specifier: "%.1f") (\(location.reviewCount))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(location.hours)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(location.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct ExploreView: View {
    @EnvironmentObject var locationService: LocationService
    @State private var searchText = ""
    @State private var selectedCategory: LocationCategory?
    
    var filteredLocations: [Location] {
        locationService.searchLocations(query: searchText, category: selectedCategory)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                
                CategoryFilterView(selectedCategory: $selectedCategory)
                
                List(filteredLocations) { location in
                    NavigationLink(destination: LocationDetailView(location: location)) {
                        LocationRowView(location: location)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Explore")
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search places...", text: $text)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct CategoryFilterView: View {
    @Binding var selectedCategory: LocationCategory?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryButton(
                    title: "All",
                    icon: "list.bullet",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }
                
                ForEach(LocationCategory.allCases, id: \.self) { category in
                    CategoryButton(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

struct CategoryButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.red : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct LocationRowView: View {
    let location: Location
    @EnvironmentObject var locationService: LocationService
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(location.category.rawValue + " • " + location.cuisineTypes.map { $0.rawValue }.prefix(2).joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(location.priceRange.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5) { i in
                            Image(systemName: i < Int(location.rating) ? "star.fill" : "star")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Text("\(location.rating, specifier: "%.1f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: {
                locationService.toggleFavorite(location)
            }) {
                Image(systemName: locationService.isFavorite(location) ? "heart.fill" : "heart")
                    .foregroundColor(locationService.isFavorite(location) ? .red : .gray)
            }
        }
        .padding(.vertical, 4)
    }
}

struct MapView: View {
    @EnvironmentObject var locationService: LocationService
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.4440, longitude: -76.4830),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
            NavigationView {
                Map(coordinateRegion: $region, annotationItems: locationService.locations) { location in
                    MapMarker(coordinate: location.coordinate, tint: .red)
                }
                .navigationTitle("Map")
            }
        }
}

struct FavoritesView: View {
    @EnvironmentObject var locationService: LocationService
    
    var favoriteLocations: [Location] {
        locationService.locations.filter { locationService.isFavorite($0) }
    }
    
    var body: some View {
        NavigationView {
            if favoriteLocations.isEmpty {
                VStack {
                    Image(systemName: "heart")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("No favorites yet")
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding(.top)
                    
                    Text("Tap the heart icon on places you love to see them here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else {
                List(favoriteLocations) { location in
                    NavigationLink(destination: LocationDetailView(location: location)) {
                        LocationRowView(location: location)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Favorites")
        }
    }
}

struct LocationDetailView: View {
    let location: Location
    @EnvironmentObject var locationService: LocationService
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(location.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: {
                            locationService.toggleFavorite(location)
                        }) {
                            Image(systemName: locationService.isFavorite(location) ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(locationService.isFavorite(location) ? .red : .gray)
                        }
                    }
                    
                    Text(location.category.rawValue)
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        HStack(spacing: 2) {
                            ForEach(0..<5) { i in
                                Image(systemName: i < Int(location.rating) ? "star.fill" : "star")
                                    .font(.subheadline)
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        Text("\(location.rating, specifier: "%.1f") (\(location.reviewCount) reviews)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(location.priceRange.rawValue)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                
                Divider()
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(location.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                // Details
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(title: "Address", value: location.address, icon: "location")
                    DetailRow(title: "Hours", value: location.hours, icon: "clock")
                    DetailRow(title: "Price Range", value: location.priceRange.description, icon: "dollarsign.circle")
                    
                    if !location.cuisineTypes.isEmpty {
                        DetailRow(title: "Cuisine", value: location.cuisineTypes.map { $0.rawValue }.joined(separator: ", "), icon: "fork.knife")
                    }
                    
                    if !location.atmosphere.isEmpty {
                        DetailRow(title: "Atmosphere", value: location.atmosphere.map { $0.rawValue }.joined(separator: ", "), icon: "face.smiling")
                    }
                    
                    if !location.features.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.red)
                                Text("Features")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                ForEach(location.features, id: \.self) { feature in
                                    HStack {
                                        Image(systemName: "checkmark")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                        Text(feature.rawValue)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                }
                
                Spacer(minLength: 100)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.body)
                        .fontWeight(.medium)
                }
            }
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.red)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// SettingsView in construction

//struct SettingsView: View {
//    @EnvironmentObject var locationService: LocationService
//    @State private var showingPreferences = false
//
//    var body: some View {
//        NavigationView {
//            List {
                            
