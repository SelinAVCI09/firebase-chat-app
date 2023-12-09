//
//  RecentMessages.swift
//  firebasechatapp
//
//  Created by Selin Avcı on 6.08.2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct RecentMessage: Codable, Identifiable{
//  .multilineTextAlignment(.leading)
//    let documentId: String
    @DocumentID var id: String?
    
    let text: String
    let email: String
    let fromId: String
    let toId: String
    let profileImageUrl: String
     let timestamp: Date
    var username: String{
        email.components(separatedBy: "@").first ?? email
    }
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
        
    }
    
//
//    init(documentId: String, data: [String: Any]){
//        self.documentId = documentId
//        self.text = data["text"] as? String ?? ""
//        self.email = data["email"] as? String ?? ""
//        self.fromId = data["fromıd"] as? String ?? ""
//        self.toId = data["toId"] as? String ?? ""
//        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
//     //   self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date:
//        Date())
//    }
    
}
