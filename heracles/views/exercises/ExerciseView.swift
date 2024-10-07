//
//  ExerciseView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 07/10/2024.
//
import SwiftUI
import YouTubePlayerKit

struct ExerciseView : View {
    @Bindable var exercise: Exercise
    @State var mode: EditMode = .inactive
    
    var body: some View {
        VStack {
            if mode == .active {
                ExerciseEditView(name: $exercise.name, instructions: $exercise.instructions, targetMuscleGroup: $exercise.targetMuscleGroup, selection: $exercise.selection, youtubeVideoUrl: $exercise.youtubeVideoUrl)
            } else {
                ScrollView {
                        VStack(alignment: .leading) {
                            YouTubePlayerView(YouTubePlayer(source: .url(exercise.youtubeVideoUrl))) { state in
                                switch state {
                                case .idle:
                                    ProgressView()
                                case .ready:
                                    EmptyView()
                                case .error(let error):
                                    Text(verbatim: "YouTube player couldn't be loaded")
                                }
                                
                            }
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            VStack(alignment: .leading) {
                                Text("Target Muscles")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(exercise.targetMuscleGroup)
                                    .font(.headline)
                                Divider()
                                Text("Secondary Muscles")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(exercise.selection.joined(separator: ", "))
                                    .font(.headline)
                                
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Material.regular)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            Text("Instructions")
                                .font(.title.bold())
                                .padding(.bottom, 5)
                            Text(exercise.instructions)
                                .font(.body)
                        }
                        .padding()
                    }
                    
                }
                
        }
        .navigationTitle(exercise.name)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .toolbar {
            EditButton()
        }
        .environment(\.editMode, $mode)
    }
}


#Preview {
    let exercise = Exercise(name: "Bench Press")
    
    exercise.instructions = """
    1. Lie flat on a bench with your feet firmly on the floor. Grip the bar slightly wider than shoulder-width.
    2. Unrack the barbell, holding it above your chest with arms fully extended.
    3. Slowly lower the bar to your mid-chest, keeping elbows at about a 45-degree angle.
    4. Push the bar back up explosively until your arms are fully extended.
    5. Inhale as you lower the bar, exhale as you push up.
    6. Repeat for the desired number of repetitions, then re-rack the bar safely.
    """
    
    exercise.targetMuscleGroup = "Chest"
    exercise.selection = ["Shoulders", "Triceps"]
    exercise.youtubeVideoUrl = "https://www.youtube.com/watch?v=tuwHzzPdaGc"
    
    return NavigationStack {
        ExerciseView(exercise: exercise)
    }
}
