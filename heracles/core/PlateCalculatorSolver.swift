//
//  PlateCalculatorSolver.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 11/04/2025.
//
import Foundation

// A candidate solution representation.
struct Candidate {
    // Total weight achieved by using chosen plates.
    let usedWeight: Double
    // Total number of plates used.
    let plateCount: Int
    // Plate combination: keys are plate weights, values are the counts used.
    let combination: [Plate]
    
    // Comparison: we say candidate 'a' is better than candidate 'b' if:
    // 1. a.usedWeight > b.usedWeight, or if equal,
    // 2. a.plateCount < b.plateCount.
    func isBetter(than other: Candidate) -> Bool {
        if self.usedWeight > other.usedWeight {
            return true
        } else if self.usedWeight == other.usedWeight && self.plateCount < other.plateCount {
            return true
        }
        return false
    }
}

// PlateSelector uses DP with memoization to find the best (closest) candidate.
class PlateCalculatorSolver {
    let plates: [Plate]
    let target: Double
    
    // We'll use a dictionary to cache computed results.
    // The key is a tuple: (current index, remaining as string) to avoid double precision issues.
    var memo: [String: Candidate] = [:]
    
    // Constructor assumes no need to sort by weight now but it can help the DP converge faster.
    init(plates: [Plate], target: Double) {
        // Sorting from heavy to light can be helpful.
        self.plates = plates.sorted { $0.weight > $1.weight }
        self.target = target
    }
    
    // Helper function to create a memoization key.
    private func memoKey(index: Int, remaining: Double) -> String {
        // Assuming a fixed precision of 4 decimal places
        let remKey = String(format: "%.4f", remaining)
        return "\(index)-\(remKey)"
    }
    
    /// dp(index:rem:) returns the best Candidate obtainable using plates from `index` onward, given
    /// that we can add at most `rem` more weight (without overshooting the target).
    func dp(index: Int, rem: Double) -> Candidate {
        // Base case: if no more plates to choose, return candidate with 0 additional weight.
        if index == plates.count {
            return Candidate(usedWeight: 0.0, plateCount: 0, combination: [])
        }
        
        let key = memoKey(index: index, remaining: rem)
        if let cached = memo[key] {
            return cached
        }
        
        let currentPlate = plates[index]
        // Maximum number of currentPlate we could use without exceeding the remaining weight.
        let maxUsable = min(currentPlate.count, Int(floor(rem / currentPlate.weight)))
        
        // The best candidate found starting from this state.
        // Initialize with not using any plate of this type.
        var bestCandidate = Candidate(usedWeight: 0.0, plateCount: 0, combination: [])
        
        // Try for each count i from 0 to maxUsable.
        for i in 0...maxUsable {
            let weightUsed = Double(i) * currentPlate.weight
            let newRem = rem - weightUsed
            
            // Recurse for the next plate type.
            let candidateFromRest = dp(index: index + 1, rem: newRem)
            
            // Build the candidate for this choice.
            let totalUsed = weightUsed + candidateFromRest.usedWeight
            let totalPlates = i + candidateFromRest.plateCount
            
            // Construct the combination dictionary:
            var combination = candidateFromRest.combination
            if i > 0 {
                combination
                    .append(Plate(weight: currentPlate.weight, color: currentPlate.color, width: currentPlate.width, height: currentPlate.height, count: i))
            }
            
            let candidate = Candidate(usedWeight: totalUsed,
                                      plateCount: totalPlates,
                                      combination: combination)
            
            // We prefer a candidate that:
            // 1. Uses more total weight, and if equal,
            // 2. Uses fewer plates.
            if candidate.isBetter(than: bestCandidate) {
                bestCandidate = candidate
            }
            
            // If we hit exact target, we can break early.
            if abs(totalUsed - rem - (target - rem)) < 1e-9 && (target - rem + totalUsed) == target {
                // This check here is not necessary because totalUsed is bounded by rem usage.
                // Exact matching is implicitly handled by isBetter.
                // (We may consider adding an early return if bestCandidate.usedWeight == rem.)
            }
            
            // Also, if we've reached the maximum possible weight (i.e. newRem is 0), that branch is complete.
            if newRem == 0 {
                // No more capacity left.
                break
            }
        }
        
        memo[key] = bestCandidate
        return bestCandidate
    }
    
    /// Returns the best Candidate solution for achieving as close as possible to `target` weight.
    func findOptimalCandidate() -> Candidate {
        print("Finding optimal candidate for target \(target)")
        let start = Date()
        // Start the DP with index 0 and available capacity equal to the target.
        let candidate = dp(index: 0, rem: target)
        let end = Date()
        let elapsed = end.timeIntervalSince(start)
        print("Elapsed time: \(elapsed) seconds")
        return candidate
    }
}

class PlateCalculatorSolverCache {
    var lastTarget: Double = 0.0
    var lastPlates: [Plate] = []
    var lastCandidate: Candidate?
    
    func getCandidate(for target: Double, plates: [Plate]) -> Candidate {
        if target <= 0 { // fast track for invalid values!
            return Candidate(usedWeight: 0.0, plateCount: 0, combination: [])
        }
        
        var platesEqual = plates.count == lastPlates.count
        for i in 0..<min(plates.count, lastPlates.count) {
            if plates[i] != lastPlates[i] {
                platesEqual = false
                break
            }
        }
        
        if lastTarget == target && platesEqual && lastCandidate != nil {
            return lastCandidate!
        }
        let candidate = PlateCalculatorSolver(plates: plates, target: target).findOptimalCandidate()
        lastTarget = target
        lastPlates = plates
        lastCandidate = candidate
        return candidate
    }
}

let plateCalculatorSolverCache = PlateCalculatorSolverCache()
