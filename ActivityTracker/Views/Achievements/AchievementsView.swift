import SwiftUI

/// Main achievements/awards tab view
struct AchievementsView: View {
    @EnvironmentObject var achievementService: AchievementService
    @EnvironmentObject var streakService: StreakService
    
    @State private var selectedAchievement: Achievement?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Current streak card
                    streakCard
                    
                    // Badges overview
                    badgesOverview
                    
                    // Recent unlocks
                    if !achievementService.recentUnlocks().isEmpty {
                        recentUnlocksSection
                    }
                    
                    // All badges by category
                    allBadgesSection
                }
                .padding()
            }
            .background(Color.safeBackground)
            .navigationTitle("Achievements")
            .sheet(item: $selectedAchievement) { achievement in
                BadgeDetailView(achievement: achievement)
            }
        }
    }
    
    // MARK: - Streak Card
    
    private var streakCard: some View {
        GlassCard {
            VStack(spacing: 16) {
                Text("CURRENT STREAK")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 20) {
                    // Flame icon with streak count
                    ZStack {
                        Circle()
                            .fill(.orange.opacity(0.2))
                            .frame(width: 80, height: 80)
                        
                        VStack(spacing: 2) {
                            Image(systemName: "flame.fill")
                                .font(.title)
                                .foregroundStyle(.orange)
                            
                            Text("\(streakService.currentStreak)")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(streakService.currentStreak) Days")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(streakService.streakMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("Longest: \(streakService.longestStreak) days")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Badges Overview
    
    private var badgesOverview: some View {
        GlassCard {
            VStack(spacing: 12) {
                HStack {
                    Text("BADGES")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("\(achievementService.unlockedCount())/\(achievementService.totalCount()) unlocked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.gray.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.yellow)
                            .frame(width: geometry.size.width * CGFloat(achievementService.unlockedCount()) / CGFloat(achievementService.totalCount()))
                    }
                }
                .frame(height: 8)
                
                // Recent badges preview
                HStack(spacing: 8) {
                    ForEach(achievementService.recentUnlocks(limit: 5), id: \.id) { unlocked in
                        if let achievement = Achievement.find(by: unlocked.achievementId) {
                            BadgeIcon(achievement: achievement, isUnlocked: true, size: 40)
                                .onTapGesture {
                                    selectedAchievement = achievement
                                }
                        }
                    }
                    
                    Spacer()
                    
                    NavigationLink {
                        AllBadgesView()
                    } label: {
                        Text("View All")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
    }
    
    // MARK: - Recent Unlocks Section
    
    private var recentUnlocksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECENT UNLOCKS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            ForEach(achievementService.recentUnlocks(limit: 3), id: \.id) { unlocked in
                if let achievement = Achievement.find(by: unlocked.achievementId) {
                    RecentUnlockCard(
                        achievement: achievement,
                        unlockedDate: unlocked.unlockedDate
                    )
                    .onTapGesture {
                        selectedAchievement = achievement
                    }
                }
            }
        }
    }
    
    // MARK: - All Badges Section
    
    private var allBadgesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(AchievementCategory.allCases, id: \.self) { category in
                categorySection(category)
            }
        }
    }
    
    private func categorySection(_ category: AchievementCategory) -> some View {
        let achievements = Achievement.allAchievements.filter { $0.category == category }
        
        return VStack(alignment: .leading, spacing: 12) {
            Text(category.displayName.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(achievements, id: \.id) { achievement in
                    BadgeIcon(
                        achievement: achievement,
                        isUnlocked: achievementService.isUnlocked(achievement),
                        size: 50
                    )
                    .onTapGesture {
                        selectedAchievement = achievement
                    }
                }
            }
        }
    }
}

// MARK: - Badge Icon

struct BadgeIcon: View {
    let achievement: Achievement
    let isUnlocked: Bool
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isUnlocked ? achievement.color.opacity(0.2) : .gray.opacity(0.1))
                .frame(width: size, height: size)
            
            Image(systemName: achievement.icon)
                .font(.system(size: size * 0.4))
                .foregroundStyle(isUnlocked ? achievement.color : .gray.opacity(0.4))
        }
        .overlay(
            Circle()
                .stroke(isUnlocked ? achievement.color.opacity(0.5) : .clear, lineWidth: 2)
        )
    }
}

// MARK: - Recent Unlock Card

struct RecentUnlockCard: View {
    let achievement: Achievement
    let unlockedDate: Date
    
    var body: some View {
        GlassCard(padding: 12) {
            HStack {
                BadgeIcon(achievement: achievement, isUnlocked: true, size: 50)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(achievement.name)
                        .font(.headline)
                    
                    Text(achievement.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(unlockedDate, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    AchievementsView()
        .environmentObject(AchievementService.shared)
        .environmentObject(StreakService.shared)
}
