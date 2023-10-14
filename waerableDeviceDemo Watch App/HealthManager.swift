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
      
    static var startOfWeek: Date {
        let calendar = Calendar.current
        guard let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else {
            fatalError("Failed to calculate the start of the week")
        }
        return sunday
    }
}


class HealthManager: ObservableObject {
    
    let healthStore = HKHealthStore()
    let steps = HKQuantityType(.stepCount)
    let calories = HKQuantityType(.activeEnergyBurned)
    let heartRate = HKQuantityType(.heartRate)
    
    @Published var activitiesQuantities: [String: String] = [:]
    
    init() {
        let healthTypes: Set = [steps, calories, heartRate]
        //if !HKHealthStore.isHealthDataAvailable() {
            Task {
                do {
                    try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
                } catch {
                    print("HealthKit not allowed \(error.localizedDescription)")
                }
            }
        //}
        
    }
    
    func fetchSteps(start: Date, end: Date, completion: @escaping (Double) -> Void) {
        print("Fetching steps from: \(start) to: \(end)")
        let predicte = HKQuery.predicateForSamples(withStart: start, end: end)
        //let predicte = HKQuery.predicateForSamples(withStart: .startOfWeek, end: end)
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicte) {
            _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("sumQuantity nil")
                return
            }
            let stepCount = quantity.doubleValue(for: .count())
            DispatchQueue.main.async {
                self.activitiesQuantities["todaysteps"] = "\(stepCount)"
                completion(stepCount)
            }
            print(stepCount)
        }
        healthStore.execute(query)
    }
    
    func fetchCalories(start: Date, end: Date, completion: @escaping (Double) -> Void) {
        print("Fetching Calories from: \(start) to: \(end)")
        let predicte = HKQuery.predicateForSamples(withStart: start, end: end)
        //let predicte = HKQuery.predicateForSamples(withStart: .startOfWeek, end: end)
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicte) {
            _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("Calories sumQuantity nil")
                return
            }
            let calories = quantity.doubleValue(for: HKUnit.kilocalorie())
            DispatchQueue.main.async {
                self.activitiesQuantities["todayCalories"] = "\(calories)"
                completion(calories)
            }
            print(calories)
        }
        healthStore.execute(query)
    }
    
    func fetchHeartRate(start: Date, end: Date, completion: @escaping (Double) -> Void) {
        print("Fetching heartRates from: \(start) to: \(end)")
        let predicte = HKQuery.predicateForSamples(withStart: start, end: end)
        //let predicte = HKQuery.predicateForSamples(withStart: .startOfWeek, end: end)
        let query = HKSampleQuery(sampleType: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
               predicate: HKQuery.predicateForSamples(withStart: .startOfWeek, end: end, options: []),
               limit: HKObjectQueryNoLimit,
               sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)]){ (query, results, error) in
            
            guard error == nil else { print("error"); return }
            
            if let tmpResults = results as? [HKQuantitySample] {
                
                // 取得したデータを１件ずつ ListRowItem 構造体に格納
                // ListRowItemは、dataSource配列に追加します。ViewのListでは、この dataSource配列を参照して心拍数を表示します。
                for item in tmpResults {
                    print(item.quantity.doubleValue(for: HKUnit(from: "count/min")))
                    item.quantity.doubleValue(for: HKUnit(from: "count/min"))
                }
                let heartRate = tmpResults.first?.quantity.doubleValue(for: HKUnit(from: "count/min"))
                DispatchQueue.main.async {
                    self.activitiesQuantities["heartRates"] = "\(heartRate)"
                    completion(heartRate ?? 0)
                }
            }
        }
        healthStore.execute(query)
    }
}

