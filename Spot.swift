//
//  Spot.swift
//  Snacktacular
//
//  Created by J. Lozano on 11/4/18.
//  Copyright © 2018 John Gallaugher. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase
import MapKit

class Spot: NSObject, MKAnnotation {
    var name: String
    var address: String
    var coordinate: CLLocationCoordinate2D
    var averageRating: Double
    var numberOfReviews: Int
    var postingUserID: String
    var documentID: String
    
    var longitude: CLLocationDegrees{
        return coordinate.longitude
    }
    
    var latitude: CLLocationDegrees{
        return coordinate.latitude
    }
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    var title: String?{
        return name
    }
    var subtitle: String?{
        return address
    }
    
    var dictionary: [String: Any]{
        return ["name": name, "address": address, "longitude": longitude, "latitude": latitude, "averageRating": averageRating, "numberOfReviews": numberOfReviews, "postingUserID": postingUserID]
    }
    
    
    init(name: String, address: String, coordinate: CLLocationCoordinate2D, averageRating: Double, numberOfReviews: Int, postingUserID: String, documentID: String) {
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.averageRating = averageRating
        self.numberOfReviews = numberOfReviews
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    
   convenience override init(){
        self.init(name: "", address: "", coordinate: CLLocationCoordinate2D(), averageRating: 0.0, numberOfReviews: 0, postingUserID: "", documentID: "")
    }
    convenience init(dictionary: [String: Any]){
        let name = dictionary["name"] as! String? ?? ""
        let address = dictionary["address"] as! String? ?? ""
        let latitude = dictionary["latitude"] as! CLLocationDegrees? ?? 0.0
        let longitude = dictionary["longitude"] as! CLLocationDegrees? ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let averageRating = dictionary["averageRating"] as! Double? ?? 0.0
        let numberOfReviews = dictionary["numberOfReviews"] as! Int? ?? 0
        let postingUserID = dictionary["pstingUserID"] as! String? ?? ""
        self.init(name: name, address: address, coordinate: coordinate, averageRating: averageRating, numberOfReviews: numberOfReviews, postingUserID: postingUserID, documentID: "")
    }

    func saveData(completed: @escaping (Bool) -> ()){
        let db = Firestore.firestore()
        // Grab the User ID
        guard let postingUserID = (Auth.auth().currentUser?.uid) else{
            print("***** ERROR: Invalid posting User ID")
            return completed(false)
        }
        self.postingUserID = postingUserID
        // Create dict representing saved data
        let dataToSave = self.dictionary
        // If we have saved a record, we'll have a documentID
        if self.documentID != ""{
            let ref = db.collection("spots").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("***** ERROR: updating document \(self.documentID) \(error.localizedDescription)")
                    completed(false)
                }
                else{
                    completed(true)
                }
            }
        }
        else{
            var ref: DocumentReference? = nil
            ref = db.collection("spots").addDocument(data: dataToSave){ (error) in
                if let error = error {
                    print("***** ERROR: creating new document \(error.localizedDescription)")
                    completed(false)
                }
                else{
                    self.documentID = ref!.documentID
                    completed(true)
                }
            }
        }
    }
    
    func updateAverageRating(completed: @escaping () -> ()){
        let db = Firestore.firestore()
        let reviewsRef = db.collection("spots").document(self.documentID).collection("reviews")
        reviewsRef.getDocuments { (querySnapshot, error) in
            guard error == nil else{
                print("GRRRR \(error?.localizedDescription)")
                return completed()
            }
            var ratingTotal = 0.0
            for document in querySnapshot!.documents { //go through all of the reviews documents
                let reviewDictionary = document.data()
                let rating = reviewDictionary["rating"] as! Int? ?? 0
                ratingTotal = ratingTotal + Double(rating)
            }
            self.averageRating = ratingTotal / Double(querySnapshot!.count)
            self.numberOfReviews = querySnapshot!.count
            let dataToSave = self.dictionary
            let spotRef = db.collection("spots").document(self.documentID)
            spotRef.setData(dataToSave) { error in
                guard error == nil else{
                    print("GRRRRR \(error?.localizedDescription)")
                    return completed()
                }
                completed()
            }
        }
    }
}
