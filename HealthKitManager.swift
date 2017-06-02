//
//  HealthKitManager.swift
//  HealtRate WatchKit Extension
//
//  Created by duruldalkanat on 6/2/17.
//  Copyright © 2017 duruldalkanat. All rights reserved.
//

import Foundation
import HealthKit

protocol HeartRateDelegate {
    func heartRateUpdated(heartRateSamples: [HKSample])
}

class HealthKitManager: NSObject {
    
    static let sharedInstance = HealthKitManager()
    
    private override init() {}
    
    let healthStore = HKHealthStore()
    
    // This'll be the last value we received.
    var anchor: HKQueryAnchor?
    var heartRateDelegate: HeartRateDelegate?
    
    func authorizeHealthKit(_ completion: @escaping ((_ success: Bool, _ error: Error?) -> Void)) {
        
        guard let heartRateType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        let typesToShare = Set([HKObjectType.workoutType(), heartRateType])
        let typesToRead = Set([HKObjectType.workoutType(), heartRateType])
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            print("Was authorization successful? \(success)")
            completion(success, error)
        }
    }
    
    func createHeartRateStreamingQuery(_ workoutStartDate: Date) -> HKQuery? {
        
        guard let heartRateType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return nil
        }
        
        let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictEndDate)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate])
        
        // We keep track of the last heart rate we received, and then from there on only get new ones.
        let heartRateQuery = HKAnchoredObjectQuery(type: heartRateType, predicate: compoundPredicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) in
            
            guard let newAnchor = newAnchor,
                let sampleObjects = sampleObjects else {
                    return
            }
            self.anchor = newAnchor
            
            // We've created a heart rate query and a delegate so other classes can call this query to receive heart rate samples.
            self.heartRateDelegate?.heartRateUpdated(heartRateSamples: sampleObjects)
        }
        
        heartRateQuery.updateHandler = {(query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            
            guard let newAnchor = newAnchor,
                let sampleObjects = sampleObjects else {
                    return
            }
            self.anchor = newAnchor
            self.heartRateDelegate?.heartRateUpdated(heartRateSamples: sampleObjects)
        }
        return heartRateQuery
    }
}
