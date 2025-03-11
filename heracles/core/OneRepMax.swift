//
//  OneRepMax.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 03/03/2025.
//

// Utitlites for calculating one rep max for different exercises.


// source: http://articles.reactivetrainingsystems.com/2015/11/29/beginning-rts/
// archived version: https://web.archive.org/web/20231013123004/http://articles.reactivetrainingsystems.com/2015/11/29/beginning-rts/

// 1-12 reps,
// 6.5-10 RPE in 0.5 increments
// maps reps an rpe into percentage of 1rm
let e1rmTable: [[Double]] = [
    [100.0,  95.5,  92.2,  89.2,  86.3,  83.7,  81.1,  78.6,  76.2,  73.9,  70.7,  68.0],  // RPE 10
    [97.8,   93.9,  90.7,  87.8,  85.0,  82.4,  79.9,  77.4,  75.1,  72.3,  69.4,  66.7],  // RPE 9.5
    [95.5,   92.2,  89.2,  86.3,  83.7,  81.1,  78.6,  76.2,  73.9,  70.7,  68.0,  65.3],  // RPE 9
    [93.9,   90.7,  87.8,  85.0,  82.4,  79.9,  77.4,  75.1,  72.3,  69.4,  66.7,  64.0],  // RPE 8.5
    [92.2,   89.2,  86.3,  83.7,  81.1,  78.6,  76.2,  73.9,  70.7,  68.0,  65.3,  62.6],  // RPE 8
    [90.7,   87.8,  85.0,  82.4,  79.9,  77.4,  75.1,  72.3,  69.4,  66.7,  64.0,  61.3],  // RPE 7.5
    [89.2,   86.3,  83.7,  81.1,  78.6,  76.2,  73.9,  70.7,  68.0,  65.3,  62.6,  59.9],  // RPE 7
    [87.8,   85.0,  82.4,  79.9,  77.4,  75.1,  72.3,  69.4,  66.7,  64.0,  61.3,  58.6]   // RPE 6.5
]

// Calculate 1rm based on reps, weight and rpe
func oneRepMax(reps: Int, weight: Double, rpe: Double) -> Double {
    let percentage = e1rmTable[Int(rpe * 2 - 13)][reps - 1]
    return weight / percentage
}

// calculate 1rm based on reps and weight
func oneRepMax(reps: Int, weight: Double) -> Double {
    // Epley method for 1rm calculation
    // TODO: experminent with other methods
    return weight * (1 + Double(reps) / 30)
}
