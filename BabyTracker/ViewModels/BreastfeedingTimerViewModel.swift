//
//  BreastfeedingTimerViewModel.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//  Updated: 2026-02-13 - Simplified unified interface
//

import Foundation
import Combine
import SwiftData

enum BreastSide {
    case left
    case right
}

class BreastfeedingTimerViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentSide: BreastSide = .left
    @Published var isRunning = false
    @Published var hasStarted = false
    
    @Published var leftDuration: TimeInterval = 0
    @Published var rightDuration: TimeInterval = 0
    
    var startTime: Date?
    private var currentStartTime: Date?
    private var pausedDuration: TimeInterval = 0
    
    private var timer: AnyCancellable?
    private let baby: Baby
    
    // MARK: - Computed Properties
    
    var currentDuration: TimeInterval {
        currentSide == .left ? leftDuration : rightDuration
    }
    
    var totalDuration: TimeInterval {
        leftDuration + rightDuration
    }
    
    var formattedCurrentTime: String {
        formatTime(currentDuration)
    }
    
    var formattedTotalTime: String {
        formatTime(totalDuration)
    }
    
    var formattedStartTime: String {
        guard let start = startTime else { return "--:--" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: start)
    }
    
    var formattedEndTime: String {
        guard let start = startTime else { return "--:--" }
        let end = start.addingTimeInterval(totalDuration)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: end)
    }
    
    // MARK: - Initialization
    
    init(baby: Baby) {
        self.baby = baby
    }
    
    // MARK: - Actions
    
    func start(side: BreastSide) {
        guard !hasStarted else { return }
        
        currentSide = side
        hasStarted = true
        isRunning = true
        startTime = Date()
        currentStartTime = Date()
        
        startTimer()
    }
    
    func togglePause() {
        if isRunning {
            pause()
        } else {
            resume()
        }
    }
    
    func stop() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }
    
    func switchSide() {
        // Pause current side
        if isRunning {
            pause()
        }
        
        // Switch side
        currentSide = currentSide == .left ? .right : .left
        
        // Reset for new side
        pausedDuration = currentSide == .left ? leftDuration : rightDuration
        currentStartTime = Date()
        
        // Resume
        resume()
    }
    
    func saveRecord(context: ModelContext) {
        let record = FeedingRecord(
            babyId: baby.id,
            timestamp: startTime ?? Date(),
            method: .breastfeeding
        )
        record.leftDuration = Int(leftDuration)
        record.rightDuration = Int(rightDuration)
        
        context.insert(record)
        try? context.save()
        
        reset()
    }
    
    func reset() {
        stop()
        leftDuration = 0
        rightDuration = 0
        pausedDuration = 0
        startTime = nil
        currentStartTime = nil
        hasStarted = false
        currentSide = .left
    }
    
    // MARK: - Private Methods
    
    private func startTimer() {
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateDuration()
            }
    }
    
    private func pause() {
        guard isRunning else { return }
        
        isRunning = false
        timer?.cancel()
        timer = nil
        
        // Save paused duration
        if currentSide == .left {
            pausedDuration = leftDuration
        } else {
            pausedDuration = rightDuration
        }
    }
    
    private func resume() {
        guard !isRunning else { return }
        
        isRunning = true
        currentStartTime = Date()
        startTimer()
    }
    
    private func updateDuration() {
        guard let start = currentStartTime else { return }
        let elapsed = pausedDuration + Date().timeIntervalSince(start)
        
        if currentSide == .left {
            leftDuration = elapsed
        } else {
            rightDuration = elapsed
        }
    }
    
    private func formatTime(_ duration: TimeInterval) -> String {
        let total = Int(duration)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    deinit {
        timer?.cancel()
    }
}
