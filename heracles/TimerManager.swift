//
//  TimerManager.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 22/02/2025.
//
import SwiftUI

class TimerManager: ObservableObject {
    @Published var isRunning = false
    @Published var elapsedTime: TimeInterval = 0
    private var lastTime: Date?
    private var timer: Timer?
    
    private let elapsedKey = "elapsedTime"
    private let lastTimeKey = "lastTime"
    private let isRunningKey = "isRunning"
    
    init() {
        loadState()
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func start() {
        if !isRunning {
            isRunning = true
            runTimer()
            saveState()
        }
    }
    
    func pause() {
        if isRunning {
            isRunning = false
            timer?.invalidate()
            saveState()
        }
    }
    
    func reset() {
        elapsedTime = 0
        isRunning = false
        timer?.invalidate()
        saveState()
    }
    
    private func runTimer() {
        lastTime = Date.now
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.isRunning {
                self.elapsedTime += Date().timeIntervalSince(self.lastTime!)
                self.lastTime = Date.now
            }
        }
    }
    
    @objc private func appWillResignActive() {
        timer?.invalidate()
        saveState()
    }
    
    @objc private func appDidBecomeActive() {
        loadState()
        if isRunning {
            runTimer()
        }
    }
    
    private func saveState() {
        UserDefaults.standard.set(elapsedTime, forKey: elapsedKey)
        UserDefaults.standard.set(isRunning, forKey: isRunningKey)
        UserDefaults.standard.set(lastTime?.timeIntervalSince1970, forKey: lastTimeKey)
        UserDefaults.standard.synchronize()
    }
    
    private func loadState() {
        print("loading state")
        elapsedTime = UserDefaults.standard.double(forKey: elapsedKey)
        isRunning = UserDefaults.standard.bool(forKey: isRunningKey)
        lastTime = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: lastTimeKey))
        if isRunning {
            elapsedTime += Date().timeIntervalSince(lastTime!)
            runTimer()
        }
    }
}
