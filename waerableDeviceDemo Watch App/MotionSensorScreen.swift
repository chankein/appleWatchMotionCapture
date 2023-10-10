//
//  MotionSensorScreen.swift
//  waerableDeviceDemo Watch App
//
//  Created by kein chan on 2023/10/09.
//

import SwiftUI
import Foundation
import CoreMotion
import HealthKit

struct MotionSensorScreen: View {
    @ObservedObject var sensor = MotionSensor()
    
    var body: some View {
        VStack {
            Form {
                Section {
                    Text("x: \(sensor.acceX) y: \(sensor.acceY) z: \(sensor.acceZ)")
                } header: {
                    Text("加速度")
                }
                
                Section {
                    Text("x: \(sensor.rotX) y: \(sensor.rotY) z: \(sensor.rotZ)")
                } header: {
                    Text("回転速度")
                }
                /*
                Section {
                    Text("\(sensor.heartRate) BPM")
                } header: {
                    Text("Heart Rate")
                }
                */
                Section {
                    Text("\(sensor.stepCount) 歩")
                } header: {
                    Text("歩数")
                }
            }
            Button(action: {
                sensor.isStarted ? sensor.stop() : sensor.start()
            }) {
                Text(sensor.isStarted ? "記録停止" : "記録開始")
            }
        }
        .font(.system(size: 13))
        .onReceive(sensor.$stepCount, perform: { newValue in
                    print("View received stepCount: \(newValue)")
                })
    }
}

class MotionSensor: NSObject, ObservableObject {
    let motionManager = CMMotionManager()
    let healthStore = HKHealthStore()
    
    var startTime: Date = Date()
    var endTime: Date = Date()
    
    @Published var heartRate = "0"
    @Published var stepCount = "0"
    
    @Published var isStarted = false
    
    @Published var acceX = "0.0"
    @Published var acceY = "0.0"
    @Published var acceZ = "0.0"
    
    @Published var rotX = "0.0"
    @Published var rotY = "0.0"
    @Published var rotZ = "0.0"
    @StateObject var healthManager = HealthManager()
    
    func start() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.5
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!,
                                                   withHandler: {(motion:CMDeviceMotion?, error:Error?) in
                self.updateMotionData(deviceMotion: motion!)
            })
        }
        
        
        if HKHealthStore.isHealthDataAvailable() {
            startFetchingHeartRate()
            
        }
        
        startTime = Date()
        isStarted = true
    }
    
    func stop() {
        isStarted = false
        motionManager.stopDeviceMotionUpdates()
        endTime = Date()
        healthManager.fetchSteps(start: startTime, end: endTime) { [weak self] stepCount in
            DispatchQueue.main.async {
                self?.stepCount = "\(Int(stepCount))"
                print("Updated stepCount: \(self?.stepCount ?? "nil")")
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
    
    func startFetchingHeartRate() {
        
        }
        
        func stopFetchingHeartRate() {
        }
    
}


#Preview {
    MotionSensorScreen()
}
