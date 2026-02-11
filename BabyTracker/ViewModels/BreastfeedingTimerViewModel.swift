//
//  BreastfeedingTimerViewModel.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//  Updated for BDD tests: 2026-02-11
//

import Foundation
import Combine
import SwiftData

class BreastfeedingTimerViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var isLeftRunning = false
    @Published var isRightRunning = false
    @Published var hasStarted = false
    
    @Published var leftElapsed: TimeInterval = 0
    @Published var rightElapsed: TimeInterval = 0
    
    var leftStartTime: Date?
    var rightStartTime: Date?
    
    private var leftPausedDuration: TimeInterval = 0
    private var rightPausedDuration: TimeInterval = 0
    
    private var leftTimer: AnyCancellable?
    private var rightTimer: AnyCancellable?
    
    private let baby: Baby
    
    // MARK: - Computed Properties
    
    var totalDuration: TimeInterval {
        leftElapsed + rightElapsed
    }
    
    var leftElapsedTime: String {
        formatTime(leftElapsed)
    }
    
    var rightElapsedTime: String {
        formatTime(rightElapsed)
    }
    
    var formattedTotalTime: String {
        formatTime(totalDuration)
    }
    
    // MARK: - Initialization
    
    init(baby: Baby) {
        self.baby = baby
    }
    
    // MARK: - Left Side Actions
    
    func startLeft() {
        guard !isLeftRunning else { return }
        
        hasStarted = true
        isLeftRunning = true
        leftStartTime = Date()
        
        leftTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateLeftElapsed()
            }
    }
    
    func pauseLeft() {
        guard isLeftRunning else { return }
        
        isLeftRunning = false
        leftTimer?.cancel()
        leftTimer = nil
        leftPausedDuration = leftElapsed
    }
    
    func resumeLeft() {
        guard !isLeftRunning else { return }
        
        isLeftRunning = true
        leftStartTime = Date()
        
        leftTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateLeftElapsed()
            }
    }
    
    func stopLeft() {
        pauseLeft()
    }
    
    // MARK: - Right Side Actions
    
    func startRight() {
        guard !isRightRunning else { return }
        
        hasStarted = true
        isRightRunning = true
        rightStartTime = Date()
        
        rightTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateRightElapsed()
            }
    }
    
    func pauseRight() {
        guard isRightRunning else { return }
        
        isRightRunning = false
        rightTimer?.cancel()
        rightTimer = nil
        rightPausedDuration = rightElapsed
    }
    
    func resumeRight() {
        guard !isRightRunning else { return }
        
        isRightRunning = true
        rightStartTime = Date()
        
        rightTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateRightElapsed()
            }
    }
    
    func stopRight() {
        pauseRight()
    }
    
    // MARK: - Switch Side Action
    
    func switchSide() {
        // Stop left, start right
        if isLeftRunning {
            stopLeft()
        }
        startRight()
    }
    
    // MARK: - Save Record
    
    func saveRecord(context: ModelContext) {
        let record = FeedingRecord(
            baby: baby,
            type: .breastfeeding,
            leftDuration: leftElapsed,
            rightDuration: rightElapsed,
            timestamp: Date()
        )
        
        context.insert(record)
        try? context.save()
        
        // Reset
        reset()
    }
    
    func reset() {
        stopLeft()
        stopRight()
        
        leftElapsed = 0
        rightElapsed = 0
        leftPausedDuration = 0
        rightPausedDuration = 0
        leftStartTime = nil
        rightStartTime = nil
        hasStarted = false
    }
    
    // MARK: - Private Methods
    
    private func updateLeftElapsed() {
        guard let start = leftStartTime else { return }
        leftElapsed = leftPausedDuration + Date().timeIntervalSince(start)
    }
    
    private func updateRightElapsed() {
        guard let start = rightStartTime else { return }
        rightElapsed = rightPausedDuration + Date().timeIntervalSince(start)
    }
    
    // MARK: - Formatters
    
    private func formatTime(_ duration: TimeInterval) -> String {
        let total = Int(duration)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    deinit {
        leftTimer?.cancel()
        rightTimer?.cancel()
    }
}

// MARK: - BreastSide Enum

enum BreastSide {
    case left
    case right
}
