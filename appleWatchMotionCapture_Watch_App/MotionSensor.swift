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
import Combine

class MotionSensor: NSObject, ObservableObject {
    let motionManager = CMMotionManager()
    let healthStore = HKHealthStore()
    
    var startTime: Date = Date()
    var endTime: Date = Date()
    
    @Published var motionDataPoints: [MotionData] = []
    
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
    private var dataSaveTimer: Timer?
    
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
        dataSaveTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, 
                                             selector: #selector(saveMotionDataPoint), userInfo: nil, repeats: true)
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
        
        // Invalidate the timer
        dataSaveTimer?.invalidate()
        dataSaveTimer = nil
        
        // Save all collected data points
        saveAllMotionData()
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
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    @objc private func saveMotionDataPoint() {
        let newMotionData = MotionData(
            timestamp: Date(),
            acceX: acceX,
            acceY: acceY,
            acceZ: acceZ,
            rotX: rotX,
            rotY: rotY,
            rotZ: rotZ,
            stepCount: stepCount,
            calories: calories,
            heartRate: heartRate
        )
        motionDataPoints.append(newMotionData)
    }
    
    private func saveAllMotionData() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601  // Use ISO 8601 date encoding
        
        do {
            let data = try encoder.encode(motionDataPoints)
            // Now `data` contains the JSON data. You can write it to a file:
            let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentsDirectory.appendingPathComponent("motionData.json")
            try data.write(to: fileURL)
        } catch {
            print("Error saving motion data: \(error)")
        }
    }
    
    func uploadDataToAPI(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601  // Use ISO 8601 date encoding
        
        do {
            let data = try encoder.encode(motionDataPoints)
            let apiUrl = URL(string: "https://ryno0hub6k.execute-api.ap-northeast-1.amazonaws.com/develop/uploadMotionData")!
            
            var request = URLRequest(url: apiUrl)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    print("Error uploading data: \(error!.localizedDescription)")
                    completion(false, error) // Call the completion with the error
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    let apiError = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey : "API response status: \(httpResponse.statusCode)"])
                    print("API response status: \(httpResponse.statusCode)")
                    completion(false, apiError) // Call the completion with the API error
                    return
                }
                
                print("Data uploaded successfully!")
                completion(true, nil) // Call the completion with success
            }
            
            task.resume()
            
        } catch {
            print("Error encoding motion data: \(error)")
            completion(false, error) // <-- 添加这行
        }
    }


}

struct MotionData: Codable {
    var timestamp: Date
    var acceX: String
    var acceY: String
    var acceZ: String
    var rotX: String
    var rotY: String
    var rotZ: String
    var stepCount: String
    var calories: String
    var heartRate: String
}
