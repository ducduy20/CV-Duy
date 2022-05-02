//
//  NewMessageView.swift
//  Project CV
//
//  Created by Tran Duc Duy on 27/03/2022.
//

import SwiftUI
import SDWebImageSwiftUI

class NewMessageViewModel: ObservableObject {
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    init(){
        fetchAllUser()
    }
    private func fetchAllUser(){
        FirebaseManager.shared.firestore.collection("user").getDocuments{
            documentsSnapshot, error in
            if let error = error{
                print("Failed to fetch user :\(error)")
                return
            }
            documentsSnapshot?.documents.forEach({snapshot in
                let user = try? snapshot.data(as: ChatUser.self)
                if user?.uid != FirebaseManager.shared.auth.currentUser?.uid{
                    self.users.append(user!)
                }
                
            })
        }
        
    }
}


struct NewMessageView: View {
    let didSelectUser : (ChatUser) -> ()
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var mm = NewMessageViewModel()
    
    var body: some View {
        NavigationView{
            ScrollView{
                Text(mm.errorMessage)
                ForEach(mm.users){user in
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        didSelectUser(user)
                    } label: {
                        HStack(spacing: 16){
                            WebImage(url: URL(string: user.imageProfile))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color(.label), lineWidth: 2))
                            
                            Text(user.email).foregroundColor(Color(.label))
                        Spacer()
                        }.padding(.horizontal)
                        
                    }
                    Divider()
                        .padding(.vertical,8)

                    
                }
                
            }.navigationTitle("New Message")
                .toolbar{
                    ToolbarItemGroup(placement: .navigationBarLeading){
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Cancel")
                        }
                        
                    }
                }
        }
    }
}

struct NewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        //NewMessageView(didSelectUser:{ } )
        MainMessagesView()
    }
}
