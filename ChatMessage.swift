//
//  ChatMessage.swift
//  Project CV
//
//  Created by Tran Duc Duy on 11/04/2022.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatMessage:Codable, Identifiable{
    @DocumentID var id:String?
    let fromId,toId,text:String
    let timestamp:Date
}
