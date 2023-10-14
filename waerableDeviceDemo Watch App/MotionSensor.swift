//
//  MotionSensor.swift
//  waerableDeviceDemo Watch App
//
//  Created by kein chan on 2023/10/14.
//

import SwiftUI
import CoreMotion
import HealthKit
import Foundation

class MotionSensor: NSObject, ObservableObject {
    let motionManager = CMMotionManager()
    let healthStore = HKHealthStore()
    
    var startTime: Date = Date()
    var endTime: Date = Date()
    
    @Published var stepCount = "0"
    @Published var calories = "0"
    @Published var heartRate = "0"
    
    @Published var isStarted = false
    @Published var elapsedTime: Int = 0
    
    @Published var acceX = "0.0"
    @Published var acceY = "0.0"
    @Published var acceZ = "0.0"
    
    @Published var rotX = "0.0"
    @Published var rotY = "0.0"
    @Published var rotZ = "0.0"
    @StateObject var healthManager = HealthManager()
    
    private var timer: Timer?
    
    func start() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.5
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!,
                                                   withHandler: {(motion:CMDeviceMotion?, error:Error?) in
                self.updateMotionData(deviceMotion: motion!)
            })
        }
        
        startTime = Date()
        isStarted = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                    self?.elapsedTime += 1
                }
    }
    
    func stop() {
        isStarted = false
        motionManager.stopDeviceMotionUpdates()
        endTime = Date()
        timer?.invalidate()
        timer = nil
        elapsedTime = 0
        
        healthManager.fetchSteps(start: startTime, end: endTime) { [weak self] stepCount in
            DispatchQueue.main.async {
                self?.stepCount = "\(Int(stepCount))"
                print("Updated stepCount: \(self?.stepCount ?? "nil")")
            }
        }
        healthManager.fetchCalories(start: startTime, end: endTime) { [weak self] calories in
            DispatchQueue.main.async {
                self?.calories = "\(Int(calories))"
                print("Updated calories: \(self?.calories ?? "nil")")
            }
        }
        healthManager.fetchHeartRate(start: startTime, end: endTime) { [weak self] heartRate in
            DispatchQueue.main.async {
                self?.heartRate = "\(Int(heartRate))"
                print("Updated heartRate: \(self?.heartRate ?? "nil")")
            }
        }
    }
    
    private func updateMotionData(deviceMotion:CMDeviceMotion) {
        acceX = String(format: "%.5f", deviceMotion.userAcceleration.x)
        acceY = String(format: "%.5f", deviceMotion.userAcceleration.y)
        acceZ = String(format: "%.5f", deviceMotion.userAcceleration.z)
        rotX = String(format: "%.5f", deviceMotion.rotationRate.x)
        rotY = String(format: "%.5f", deviceMotion.rotationRate.y)
        rotZ = String(format: "%.5f", deviceMotion.rotationRate.z)
    }
    
    var elapsedTimeString: String {
            let minutes = elapsedTime / 60
            let seconds = elapsedTime % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    
}
