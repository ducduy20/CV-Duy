//
//  ChatUser.swift
//  Project CV
//
//  Created by Tran Duc Duy on 27/03/2022.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatUser:Codable, Identifiable {
    @DocumentID var id: String?
    let uid, email, imageProfile: String
    
  
}
