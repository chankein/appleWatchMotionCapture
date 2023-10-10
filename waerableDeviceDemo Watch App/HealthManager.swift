//
//  HealthManager.swift
//  waerableDeviceDemo Watch App
//
//  Created by kein chan on 2023/10/09.
//

import Foundation
import HealthKit

extension Date {
    static var startOfDay: Date{
        Calendar.current.startOfDay(for: Date())
    }
}

struct Activity{
    let id: Int
    let title: String
    let subtitle: String
    let image: String
    let amount: String
    
}

class HealthManager: ObservableObject {
    
    let healthStore = HKHealthStore()
    
    @Published var activities: [String: Activity] = [:]
    @Published var activitiesQuantities: [String: String] = [:]
    
    init() {
        let steps = HKQuantityType(.stepCount)
        let calories = HKQuantityType(.
        let healthTypes: Set = [steps]
        //let healthTypes: Set = [steps, calories]
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
            } catch {
                print("HealthKit not allowed \(error.localizedDescription)")
            }
        }
        
    }
    func fetchSteps(start: Date, end: Date, completion: @escaping (Double) -> Void) {
        print("Fetching steps from: \(start) to: \(end)")
        let steps = HKQuantityType(.stepCount)
        //let calories = HKQuantityType(.activeEnergyBurned)
        let predicte = HKQuery.predicateForSamples(withStart: start, end: end)
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicte) {
            _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("sumQuantity nil")
                return
            }
            let stepCount = quantity.doubleValue(for: .count())
            //let activity = Activity(id: 0,title: "title", subtitle: "sub", image:"figure.walk", amount:"\(stepCount)")
            DispatchQueue.main.async {
                //self.activities["todaysteps"] = activity
                self.activitiesQuantities["todaysteps"] = "\(stepCount)"
                completion(stepCount)
            }
            print(stepCount)
        }
        healthStore.execute(query)
    }
    
}

