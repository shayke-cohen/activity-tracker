import SwiftUI

/// Detail view for a single achievement badge
struct BadgeDetailView: View {
    let achievement: Achievement
    
    @EnvironmentObject var achievementService: AchievementService
    @Environment(\.dismiss) private var dismiss
    
    var isUnlocked: Bool {
        achievementService.isUnlocked(achievement)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Badge icon
                    ZStack {
                        Circle()
                            .fill(isUnlocked ? achievement.color.opacity(0.2) : .gray.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: achievement.icon)
                            .font(.system(size: 50))
                            .foregroundStyle(isUnlocked ? achievement.color : .gray.opacity(0.4))
                    }
                    .overlay(
                        Circle()
                            .stroke(isUnlocked ? achievement.color : .gray.opacity(0.3), lineWidth: 4)
                    )
                    
                    // Badge name and description
                    VStack(spacing: 8) {
                        Text(achievement.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(achievement.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Unlock status
                    if isUnlocked {
                        unlockedSection
                    } else {
                        lockedSection
                    }
                    
                    // Category
                    GlassCard(padding: 12) {
                        HStack {
                            Text("Category")
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Text(achievement.category.displayName)
                                .fontWeight(.medium)
                        }
                    }
                    
                    // Share button (if unlocked)
                    if isUnlocked {
                        GlassButton("Share Badge", icon: "square.and.arrow.up") {
                            shareBadge()
                        }
                    }
                }
                .padding()
            }
            .background(Color.safeBackground)
            .navigationTitle("Badge Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Unlocked Section
    
    private var unlockedSection: some View {
        GlassCard {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    
                    Text("UNLOCKED")
                        .font(.headline)
                        .foregroundStyle(.green)
                }
                
                if let date = achievementService.unlockedDate(for: achievement) {
                    Text(date, style: .date)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.green.opacity(0.3), lineWidth: 2)
        )
    }
    
    // MARK: - Locked Section
    
    private var lockedSection: some View {
        GlassCard {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.gray)
                    
                    Text("LOCKED")
                        .font(.headline)
                        .foregroundStyle(.gray)
                }
                
                Text("Complete the requirement to unlock this badge")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                // Progress indicator (simplified)
                requirementDisplay
            }
        }
    }
    
    private var requirementDisplay: some View {
        Group {
            switch achievement.requirement {
            case .totalWorkouts(let count):
                Text("Complete \(count) workouts")
            case .totalDistance(let meters):
                Text("Cover \(Int(meters / 1000)) km total")
            case .streakDays(let days):
                Text("Maintain a \(days)-day streak")
            case .singleWorkoutDistance(let meters, let type):
                Text("\(type.displayName) \(Int(meters / 1000)) km in one workout")
            case .morningWorkouts(let count):
                Text("Complete \(count) workouts before 8 AM")
            case .weekendWorkouts(let count):
                Text("Complete \(count) weekend workouts")
            case .differentActivities(let count):
                Text("Try \(count) different activities")
            case .laps(let count):
                Text("Swim \(count) laps in one session")
            default:
                Text("Keep working towards your goal!")
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.top, 8)
    }
    
    // MARK: - Actions
    
    private func shareBadge() {
        // Would generate and share badge image
    }
}

// MARK: - All Badges View

struct AllBadgesView: View {
    @EnvironmentObject var achievementService: AchievementService
    @State private var selectedCategory: AchievementCategory?
    @State private var selectedAchievement: Achievement?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: "All",
                            isSelected: selectedCategory == nil
                        ) {
                            selectedCategory = nil
                        }
                        
                        ForEach(AchievementCategory.allCases, id: \.self) { category in
                            FilterChip(
                                title: category.displayName,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Badges grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(filteredAchievements, id: \.id) { achievement in
                        VStack(spacing: 8) {
                            BadgeIcon(
                                achievement: achievement,
                                isUnlocked: achievementService.isUnlocked(achievement),
                                size: 70
                            )
                            
                            Text(achievement.name)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .onTapGesture {
                            selectedAchievement = achievement
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("All Badges")
        .sheet(item: $selectedAchievement) { achievement in
            BadgeDetailView(achievement: achievement)
        }
    }
    
    private var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return Achievement.allAchievements.filter { $0.category == category }
        }
        return Achievement.allAchievements
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.15))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    BadgeDetailView(achievement: Achievement.allAchievements[0])
        .environmentObject(AchievementService.shared)
}
