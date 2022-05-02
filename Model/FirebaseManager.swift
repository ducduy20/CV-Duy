//
//  FirebaseManager.swift
//  Project CV
//
//  Created by Tran Duc Duy on 23/03/2022.
//

import Foundation
import Firebase

class FirebaseManager: NSObject {
    
    let auth:Auth
    
    let storage :Storage
    let firestore: Firestore
    
    var currentUser: ChatUser?
    
    static let shared = FirebaseManager()
    override init() {
        FirebaseApp.configure()
    
    
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
    
}
