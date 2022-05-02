//
//  ChatLogView.swift
//  Project CV
//
//  Created by Tran Duc Duy on 31/03/2022.
//

import SwiftUI
import Firebase



class ChatLogViewModel: ObservableObject{
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    
    @Published var chatMessage = [ChatMessage]()
    
    var chatUser: ChatUser?
    
    
    init(chatUser:ChatUser?){
    
        self.chatUser = chatUser
        
        fetchMessage()
        
        
    }
    var firestoreListener: ListenerRegistration?
    
    func fetchMessage() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid
        else{return}
        
        guard let toId = chatUser?.uid else{return}
        
        firestoreListener?.remove()
        chatMessage.removeAll()
        
        firestoreListener = FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for message :\(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added{
                        do{
                             let cm = try change.document.data(as: ChatMessage.self)
                                self.chatMessage.append(cm)
                                print("Appen ChatMessage in chatLogView:\(Date())")
                            
                        }
                        catch{
                            print("Failed to decode message:\(error)")
                        }
                    }
                })
                DispatchQueue.main.async {
                    self.count += 1
                }
            }
    }
    
    
    
    
    
    func handelSend(){
        print(chatText)
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid
        else{
            return
        }
        
        guard let toId = chatUser?.uid
        else{
            return
        }
        //create a new collection called "messages" in firestore
        //sender
        let document = FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .document()
       let messageData = ChatMessage(id: nil, fromId: fromId, toId: toId, text: chatText, timestamp: Date())
        
        try? document.setData(from:messageData){error in
            if let error = error {
                
                self.errorMessage = "Failed to save messages into firestore\(error)"
                return
            }
            print("Successfully saved to current sending messages")
            
            self.persistRecentMessage()
            
            self.chatText = " "
            self.count += 1
        }
        //recipient
        let recipientMessage = FirebaseManager.shared.firestore.collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        try? recipientMessage.setData(from:messageData){error in
            if let error = error {
                
                self.errorMessage = "Failed to save messages into firestore\(error)"
                return
            }
            print("Recipient saved message as well")
        }
    }
    
    private func persistRecentMessage(){
        
        guard let chatUser = chatUser else {
            return
        }

        guard let uid =  FirebaseManager.shared.auth.currentUser?.uid else {return}
        guard let toId = self.chatUser?.uid else {return}
        
        
        let document=FirebaseManager.shared.firestore.collection("recent message")
            .document(uid)
            .collection("messages")
            .document(toId)
        
        let data = [
            FirebaseConstants.timestamp:Timestamp(),
            FirebaseConstants.text:self.chatText,
            FirebaseConstants.toId: uid,
            FirebaseConstants.fromId:toId,
            FirebaseConstants.imageProfile: chatUser.imageProfile ,
            FirebaseConstants.email: chatUser.email
        ] as [String : Any]
        
        document.setData(data) { error in
            if let error = error{
                self.errorMessage = "Failed to save recent messager\(error)"
                print("Failed to save recent messager\(error)")
                return
            }
        }
    }
    
    
    
    
    @Published var count = 0
    }

struct ChatLogView:View{

   // init(chatUser:ChatUser?){
   //     self.chatUser = chatUser
   //     self.mm = .init(chatUser: chatUser)
    //}

//let chatUser:ChatUser?


@ObservedObject var mm: ChatLogViewModel


var body: some View{
    
    ZStack{
        messageView
        Text(mm.errorMessage)
        VStack{
            Spacer()
            chatBottomBar
                .background(Color.white)
                }
            }
    .navigationTitle(mm.chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear{
            mm.firestoreListener?.remove()
        }
        
}
static let emptyScrollString = "Empty"

private var messageView: some View{
    ScrollView{
        ScrollViewReader{ scrollViewProxy in
            VStack{
                ForEach(mm.chatMessage){
                    message in
                    MessageView(message: message)
                    }
                    
                HStack{ Spacer() }
                    .id(Self.emptyScrollString)
            }
            .onReceive(mm.$count) {_ in
                withAnimation(.easeOut(duration: 0.5)){
                    scrollViewProxy.scrollTo(Self.emptyScrollString, anchor:.bottom)
                }
                }
            
        
            
        }
        }
    .background(Color(.init(white: 0.92, alpha: 1)))
    .safeAreaInset(edge: .bottom){
        chatBottomBar
            .background(Color(.systemBackground).ignoresSafeArea())
    }
    }

private var chatBottomBar:some View{
    HStack(spacing:16){
        
        
        
        Image(systemName:"photo.on.rectangle")
            .font(.system(size: 23))
            .foregroundColor(Color(.darkGray))
        ZStack{
            Description()
            TextEditor(text: $mm.chatText)
                .opacity(mm.chatText.isEmpty ? 0.5: 1 )
        }
        .frame(height: 40)
        Button {
            mm.handelSend()
        } label: {
            Text("Send")
                .foregroundColor(.white)
        }
            .padding(.vertical,8)
            .padding(.horizontal)
            .background(Color.blue)
            .cornerRadius(4)

    }
    .padding(.horizontal)
    .padding(.vertical,8)
}

}
private struct Description: View {
    var body: some View {
        HStack {
            Text("Description")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}

struct MessageView:View{
    let message: ChatMessage
    var body: some View{
        
        VStack{
            if message.fromId == FirebaseManager.shared.auth.currentUser?.uid{
                HStack{
                    Spacer()
                    HStack{
                        Text(message.text)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                
            }else{
                HStack{
                    
                    HStack{
                        Text(message.text)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    Spacer()
                }
               
            }
        }
        .padding(.horizontal)
        .padding(.top,8)
    }
}



struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        /*NavigationView{
            ChatLogView(chatUser: .init(data: ["uid":"tràndsjfndsvl","email":"duy@gmail.com"]))
        }*/
        MainMessagesView()
    }
}
