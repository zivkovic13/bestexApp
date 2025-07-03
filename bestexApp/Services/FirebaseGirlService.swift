//
//  FirebaseGirlService.swift
//  bestexApp
//
//  Created by MacBook Pro on 2. 7. 2025..
//


import Foundation
import FirebaseDatabase
import SwiftData

class FirebaseGirlService {
    private let databaseRef = Database.database().reference().child("girls")
    
    func fetchGirls(completion: @escaping ([Girl]) -> Void) {
        databaseRef.observeSingleEvent(of: .value) { snapshot in
            var result: [Girl] = []
            
            // Check if snapshot exists and has children
            guard snapshot.exists() else {
                print("No data found at /girls")
                completion([])
                return
            }
            
            // Loop over each child (each girl)
            for case let child as DataSnapshot in snapshot.children {
                // Each 'child' should be one girl node
                if let dict = child.value as? [String: Any] {
                    var mutableDict = dict
                    mutableDict["id"] = child.key // Assign Firebase key as id
                    
                    if let jsonData = try? JSONSerialization.data(withJSONObject: mutableDict),
                       let girl = try? JSONDecoder().decode(Girl.self, from: jsonData) {
                        result.append(girl)
                    } else {
                        print("Failed to decode child: \(child.key) with data: \(dict)")
                    }
                } else {
                    print("Child \(child.key) is not a dictionary")
                }
            }
            
            print("Loaded girls count: \(result.count)")
            completion(result)
        }
    }
    
    func updateGirl(_ girl: Girl, completion: @escaping (Bool) -> Void) {
        let girlRef = databaseRef.child(girl.id)

        let data: [String: Any] = [
            "name": girl.name,
            "yearBorn": girl.yearBorn,
            "city": girl.city,
            "wins": girl.wins,
            "imageUrls": girl.imageUrls,
            "currentRound": girl.currentRound,
            "isFavorite": girl.isFavorite
        ]

        girlRef.updateChildValues(data) { error, _ in
            if let error = error {
                print("Failed to update girl \(girl.id): \(error.localizedDescription)")
                completion(false)
            } else {
                print("Successfully updated girl \(girl.name)")
                completion(true)
            }
        }
    }

}
