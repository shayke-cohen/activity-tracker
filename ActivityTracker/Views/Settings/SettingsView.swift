import SwiftUI

/// Settings/Profile tab view
struct SettingsView: View {
    @EnvironmentObject var healthKitService: HealthKitService
    
    @AppStorage("dailyStepGoal") private var dailyStepGoal = 10000
    @AppStorage("dailyCalorieGoal") private var dailyCalorieGoal = 500.0
    @AppStorage("dailyExerciseGoal") private var dailyExerciseGoal = 30
    @AppStorage("weeklyWorkoutGoal") private var weeklyWorkoutGoal = 5
    
    @State private var showingStepGoalPicker = false
    @State private var showingCalorieGoalPicker = false
    
    var body: some View {
        NavigationStack {
            List {
                // Goals Section
                Section("Goals") {
                    goalRow(
                        title: "Daily Steps",
                        value: "\(dailyStepGoal.formatted())",
                        icon: "figure.walk",
                        color: .pink
                    ) {
                        showingStepGoalPicker = true
                    }
                    
                    goalRow(
                        title: "Daily Calories",
                        value: "\(Int(dailyCalorieGoal))",
                        icon: "flame.fill",
                        color: .orange
                    ) {
                        showingCalorieGoalPicker = true
                    }
                    
                    Stepper(value: $dailyExerciseGoal, in: 10...120, step: 5) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(.green)
                            
                            Text("Exercise Minutes")
                            
                            Spacer()
                            
                            Text("\(dailyExerciseGoal) min")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Stepper(value: $weeklyWorkoutGoal, in: 1...14) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundStyle(.blue)
                            
                            Text("Weekly Workouts")
                            
                            Spacer()
                            
                            Text("\(weeklyWorkoutGoal)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // Health Section
                Section("Health") {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                        
                        Text("HealthKit")
                        
                        Spacer()
                        
                        Text(healthKitService.isAuthorized ? "Connected" : "Not Connected")
                            .foregroundStyle(.secondary)
                    }
                    
                    NavigationLink {
                        HeartRateZonesView()
                    } label: {
                        HStack {
                            Image(systemName: "waveform.path.ecg")
                                .foregroundStyle(.red)
                            
                            Text("Heart Rate Zones")
                        }
                    }
                }
                
                // Apple Watch Section
                Section("Apple Watch") {
                    HStack {
                        Image(systemName: "applewatch")
                            .foregroundStyle(.blue)
                        
                        Text("Watch App")
                        
                        Spacer()
                        
                        Text("Connected")
                            .foregroundStyle(.secondary)
                    }
                    
                    NavigationLink {
                        ComplicationsSettingsView()
                    } label: {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(.purple)
                            
                            Text("Complications")
                        }
                    }
                }
                
                // Notifications Section
                Section("Notifications") {
                    Toggle(isOn: .constant(true)) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(.orange)
                            
                            Text("Workout Reminders")
                        }
                    }
                    
                    Toggle(isOn: .constant(true)) {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundStyle(.yellow)
                            
                            Text("Goal Achievements")
                        }
                    }
                    
                    Toggle(isOn: .constant(false)) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.gray)
                            
                            Text("Inactivity Alerts")
                        }
                    }
                }
                
                // About Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Text("Privacy Policy")
                    }
                    
                    NavigationLink {
                        Text("Terms of Service")
                    } label: {
                        Text("Terms of Service")
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingStepGoalPicker) {
                GoalPickerView(
                    title: "Daily Step Goal",
                    value: $dailyStepGoal,
                    range: 5000...30000,
                    step: 1000
                )
            }
            .sheet(isPresented: $showingCalorieGoalPicker) {
                GoalPickerView(
                    title: "Daily Calorie Goal",
                    value: Binding(
                        get: { Int(dailyCalorieGoal) },
                        set: { dailyCalorieGoal = Double($0) }
                    ),
                    range: 200...1000,
                    step: 50
                )
            }
        }
    }
    
    private func goalRow(
        title: String,
        value: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                
                Text(title)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text(value)
                    .foregroundStyle(.secondary)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Goal Picker View

struct GoalPickerView: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text(title)
                    .font(.headline)
                
                Picker("", selection: $value) {
                    ForEach(Array(stride(from: range.lowerBound, through: range.upperBound, by: step)), id: \.self) { val in
                        Text("\(val.formatted())")
                            .tag(val)
                    }
                }
                .pickerStyle(.wheel)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Set Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Placeholder Views

struct HeartRateZonesView: View {
    var body: some View {
        List {
            Section("Heart Rate Zones") {
                HRZoneRow(zone: 1, name: "Recovery", range: "< 60%", color: .gray)
                HRZoneRow(zone: 2, name: "Fat Burn", range: "60-70%", color: .blue)
                HRZoneRow(zone: 3, name: "Cardio", range: "70-80%", color: .green)
                HRZoneRow(zone: 4, name: "Peak", range: "80-90%", color: .orange)
                HRZoneRow(zone: 5, name: "Maximum", range: "> 90%", color: .red)
            }
        }
        .navigationTitle("Heart Rate Zones")
    }
}

struct HRZoneRow: View {
    let zone: Int
    let name: String
    let range: String
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text("Zone \(zone)")
                .fontWeight(.medium)
            
            Text("- \(name)")
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(range)
                .foregroundStyle(.secondary)
        }
    }
}

struct ComplicationsSettingsView: View {
    var body: some View {
        List {
            Section("Available Complications") {
                ComplicationRow(name: "Steps Progress", icon: "figure.walk")
                ComplicationRow(name: "Calories", icon: "flame.fill")
                ComplicationRow(name: "Active Workout", icon: "figure.run")
                ComplicationRow(name: "Current Streak", icon: "flame")
            }
        }
        .navigationTitle("Complications")
    }
}

struct ComplicationRow: View {
    let name: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
            
            Text(name)
            
            Spacer()
            
            Image(systemName: "checkmark")
                .foregroundStyle(.green)
        }
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            Text("""
            Privacy Policy
            
            Your privacy is important to us. Activity Tracker stores all your health and fitness data locally on your device and in Apple HealthKit.
            
            Data We Collect:
            - Workout data (duration, distance, calories)
            - Step counts from your device
            - Heart rate data during workouts
            
            How We Use Your Data:
            - To display your fitness statistics
            - To track your progress and achievements
            - To sync with Apple Health
            
            We never sell your data to third parties.
            """)
            .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}

#Preview {
    SettingsView()
        .environmentObject(HealthKitService.shared)
}
