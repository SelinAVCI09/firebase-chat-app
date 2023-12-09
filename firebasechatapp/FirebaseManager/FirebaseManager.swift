//
//  FirebaseManager.swift
//  firebasechatapp
//
//  Created by Selin Avcı on 16.07.2023.
//

import Foundation

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseStorage
//import FirebaseFirestore
//import FirebaseSharedSwift
class FirebaseManager: NSObject {
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    static let shared = FirebaseManager()
    
    override init() {
       
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        super.init()
    }
    
}

