//
//  RecentMessage.swift
//  Project CV
//
//  Created by Tran Duc Duy on 11/04/2022.
//

import Foundation
import FirebaseFirestoreSwift

struct RecentMessage: Codable,Identifiable {
    @DocumentID var id: String?
    let text, email: String
    let fromId, toId: String
    let imageProfile: String
    let timestamp: Date
    
    var username:String{
        email.components(separatedBy: "@").first ?? email
        
    }
    
    var timeAgo: String{
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
        
    }

}
