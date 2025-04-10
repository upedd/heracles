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
    private var id: String
    
    private let elapsedKey = "elapsedTime"
    private let lastTimeKey = "lastTime"
    private let isRunningKey = "isRunning"
    
    static private var instances = [String: TimerManager]()
    
    static func make(id: String) -> TimerManager {
        if let existingInstance = instances[id] {
            return existingInstance
        } else {
            let newInstance = TimerManager(id: id)
            instances[id] = newInstance
            return newInstance
        }
    }
    
    private init(id: String) {
        print("Constructing TimerManager with id: \(id)")
        self.id = id
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
            self.elapsedTime += Date().timeIntervalSince(self.lastTime!)
            saveState()
        }
        
    }
    
    func reset() {
        elapsedTime = 0
        isRunning = false
        //timer?.invalidate()
        saveState()
    }
    
    private func runTimer() {
        lastTime = Date.now
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//            if self.isRunning {
//                self.elapsedTime += Date().timeIntervalSince(self.lastTime!)
//                self.lastTime = Date.now
//            }
//        }
    }
    
    @objc private func appWillResignActive() {
        //timer?.invalidate()
        
        
        saveState()
    }
    
    @objc private func appDidBecomeActive() {
        loadState()
        if isRunning {
            runTimer()
        }
    }
    
    private func saveState() {
        UserDefaults.standard.set(elapsedTime, forKey: id + "." + elapsedKey)
        UserDefaults.standard.set(isRunning, forKey: id + "." + isRunningKey)
        UserDefaults.standard.set(lastTime?.timeIntervalSince1970, forKey: id + "." + lastTimeKey)
        UserDefaults.standard.synchronize()
    }
    
    private func loadState() {
        elapsedTime = UserDefaults.standard.double(forKey: id + "." + elapsedKey)
        isRunning = UserDefaults.standard.bool(forKey: id + "." + isRunningKey)
        lastTime = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: id + "." + lastTimeKey))
        if isRunning {
            elapsedTime += Date().timeIntervalSince(lastTime!)
            runTimer()
        }
    }
}
