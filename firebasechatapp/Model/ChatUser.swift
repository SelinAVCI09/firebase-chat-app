//
//  kullanicimesajlar.swift
//  firebasechatapp
//
//  Created by Selin Avcı on 20.07.2023.
//

import Foundation
import Firebase
import FirebaseAuth

struct ChatUser : Identifiable {
    var id: String{ uid }
    let uid, email, profileImageUrl: String
    
    init(data :[String: Any]){
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
            
    }
    }

