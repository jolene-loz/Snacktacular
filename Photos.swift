//
//  Photos.swift
//  Snacktacular
//
//  Created by J. Lozano on 11/20/18.
//  Copyright © 2018 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Photos {
    var photoArray: [Photo] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    
    
    func loadData(spot: Spot, completed: @escaping () -> ()) {
        guard spot.documentID != "" else {
            return
        }
    
        
        let storage = Storage.storage()
        db.collection("spots").document(spot.documentID).collection("photos").addSnapshotListener { (QuerySnapshot, error) in
        guard error == nil else {
            print("error")
            return completed()
        }
        
            
        self.photoArray = []
        var loadAttempts = 0
        let storageRef = storage.reference().child(spot.documentID)
        for document in QuerySnapshot!.documents {
            let photo = Photo(dictionary: document.data())
            photo.documentUUID = document.documentID
            self.photoArray.append(photo)
            
            let photoRef = storageRef.child(photo.documentUUID)
            photoRef.getData(maxSize: 25 * 1025 * 1025){ data, error in
                print("ERROR: An error occured while reading data from a file ref \(error?.localizedDescription)" )
                if loadAttempts >= (QuerySnapshot!.count){
                    return completed()
                } else {
                    let image = UIImage(data: data!)
                    photo.image = image!
                    loadAttempts += 1
                    if loadAttempts >= (QuerySnapshot!.count){
                        return completed()
                    }
                }
            }
        }
    completed()
            
    }
 }
    
    
    
}
