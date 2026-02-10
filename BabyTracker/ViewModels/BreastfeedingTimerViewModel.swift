//
//  BreastfeedingTimerViewModel.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import Foundation
import Combine

class BreastfeedingTimerViewModel: ObservableObject {
    @Published var currentSide: BreastSide = .left
    @Published var isRunning = false
    @Published var hasStarted = false
    
    @Published var leftDuration: TimeInterval = 0
    @Published var rightDuration: TimeInterval = 0
    
    var startTime = Date()
    private var currentStartTime: Date?
    private var timer: Timer?
    
    // MARK: - Computed Properties
    
    var totalDuration: TimeInterval {
        leftDuration + rightDuration
    }
    
    var currentSideDuration: TimeInterval {
        currentSide == .left ? leftDuration : rightDuration
    }
    
    var formattedCurrentTime: String {
        formatTime(currentSideDuration)
    }
    
    var formattedTotalTime: String {
        formatTime(totalDuration)
    }
    
    var formattedStartTime: String {
        formatDateTime(startTime)
    }
    
    var formattedEndTime: String {
        formatDateTime(Date())
    }
    
    // MARK: - Actions
    
    func start(side: BreastSide) {
        currentSide = side
        hasStarted = true
        startTime = Date()
        resume()
    }
    
    func togglePause() {
        if isRunning {
            pause()
        } else {
            resume()
        }
    }
    
    func switchSide() {
        // Save current side duration before switching
        if isRunning {
            updateCurrentDuration()
        }
        
        // Switch side
        currentSide = currentSide == .left ? .right : .left
        
        // If was running, continue timing on new side
        if isRunning {
            currentStartTime = Date()
        }
    }
    
    func stop() {
        if isRunning {
            updateCurrentDuration()
        }
        pause()
    }
    
    // MARK: - Private Methods
    
    private func resume() {
        guard !isRunning else { return }
        
        isRunning = true
        currentStartTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateCurrentDuration()
        }
    }
    
    private func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        
        if let start = currentStartTime {
            let elapsed = Date().timeIntervalSince(start)
            if currentSide == .left {
                leftDuration += elapsed
            } else {
                rightDuration += elapsed
            }
            currentStartTime = nil
        }
    }
    
    private func updateCurrentDuration() {
        guard let start = currentStartTime else { return }
        
        let elapsed = Date().timeIntervalSince(start)
        
        if currentSide == .left {
            leftDuration += elapsed
        } else {
            rightDuration += elapsed
        }
        
        currentStartTime = Date()
    }
    
    // MARK: - Formatters
    
    private func formatTime(_ duration: TimeInterval) -> String {
        let total = Int(duration)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    deinit {
        timer?.invalidate()
    }
}
