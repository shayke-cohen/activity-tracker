import SwiftUI

/// Animated progress rings similar to Apple Fitness
struct ProgressRingsView: View {
    let moveProgress: Double
    let exerciseProgress: Double
    
    @State private var animatedMove: Double = 0
    @State private var animatedExercise: Double = 0
    
    var body: some View {
        ZStack {
            // Move Ring (outer)
            RingView(
                progress: animatedMove,
                color: .moveRing,
                lineWidth: 22
            )
            .frame(width: 160, height: 160)
            
            // Exercise Ring (inner)
            RingView(
                progress: animatedExercise,
                color: .exerciseRing,
                lineWidth: 22
            )
            .frame(width: 110, height: 110)
            
            // Center content
            VStack(spacing: 2) {
                Text("\(Int(moveProgress * 100))%")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Move")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedMove = moveProgress
                animatedExercise = exerciseProgress
            }
        }
        .onChange(of: moveProgress) { _, newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                animatedMove = newValue
            }
        }
        .onChange(of: exerciseProgress) { _, newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                animatedExercise = newValue
            }
        }
    }
}

/// Individual ring view
struct RingView: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    AngularGradient.ringGradient(color: color),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            // End cap glow for completion
            if progress >= 1.0 {
                Circle()
                    .trim(from: 0, to: 0.001)
                    .stroke(color, lineWidth: lineWidth)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: color, radius: 5)
            }
            
            // Overflow indicator (second lap)
            if progress > 1.0 {
                Circle()
                    .trim(from: 0, to: min(progress - 1.0, 1.0))
                    .stroke(
                        color.opacity(0.5),
                        style: StrokeStyle(lineWidth: lineWidth - 4, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }
        }
    }
}

/// Compact ring for smaller displays
struct CompactRingView: View {
    let progress: Double
    let color: Color
    let icon: String
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 6)
            
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
        }
        .frame(width: 40, height: 40)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 30) {
        ProgressRingsView(moveProgress: 0.85, exerciseProgress: 0.6)
        
        HStack(spacing: 20) {
            CompactRingView(progress: 0.7, color: .moveRing, icon: "flame.fill")
            CompactRingView(progress: 0.5, color: .exerciseRing, icon: "figure.walk")
        }
    }
    .padding()
}
