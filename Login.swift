//
//  Login.swift
//  Project CV
//
//  Created by Tran Duc Duy on 20/03/2022.
//

import SwiftUI
import Firebase
import os.log
import FirebaseFirestore




struct Login: View {
    let  didCompleteLoginProcess : () -> ()
    
    
    @State private var loginIsMode = false
    @State private var email = ""
    @State private var password = ""
    
    @State private var ShowImagePicker = false
    
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack(spacing: 12){
                    
                    Picker(selection: $loginIsMode, label: Text("Login here")){
                        Text("Login").tag(true)
                        Text("Create Acount").tag(false)
                    }.pickerStyle(.segmented)
                    
                    if !loginIsMode{
                        Button {
                            ShowImagePicker.toggle()
                            
                        } label: {
                            VStack{
                                if let image = self.image{
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 128, height: 128)
                                        .cornerRadius(64)
                                }
                                else{
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 70))
                                    
                                        .padding()
                                        .foregroundColor(Color(.label))
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64)
                                .stroke(Color.black,lineWidth: 3))
                        }
                        
                    }
                    Group{
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        SecureField("Password", text: $password)
                    }
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(7)
                    
                    Button {
                        handlecAction()
                    } label: {
                        HStack{
                            Spacer()
                            Text(loginIsMode ? "Login" :"Creat Account")
                                .foregroundColor(.white)
                                .padding(.vertical,10)
                                .font(.system(size: 14,weight: .bold))
                            Spacer()
                            
                        }.background(.blue)
                    }
                    Text(self.loginMessage)
                        .foregroundColor(Color.red)
                }.padding()
                
                
            }.navigationTitle(loginIsMode ?"Login" : "Creat Acount")
                .background(Color(.init(white: 0, alpha: 0.07)).ignoresSafeArea())
            
            
            
            
            
            
            
            
        }.fullScreenCover(isPresented: $ShowImagePicker, onDismiss: nil){
           
            ImagePicker(image: $image)
        }
    }
    @State private var image: UIImage?
    
    private func handlecAction(){
        if loginIsMode{
            
            loginUser()
        }
        else{
            CreatNewAccount()
            
        }
    }
    
    private func loginUser(){
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password){
            result,err in
            if let err = err{
                print("Failed to login user", err)
                self.loginMessage = "Failed to login user:\(err)"
                return
            }
            
            print("Successfully login user: \(result?.user.uid ?? "")")
            self.loginMessage = "Successfully login  user: \(result?.user.uid ?? "")"
            
            
            self.didCompleteLoginProcess()
            
        }
        
    }
    
    @State var loginMessage = ""
    private func CreatNewAccount(){
        if self.image == nil{
            self.loginMessage = "You must select an avatar image"
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password){
            result,err in
            if let err = err{
                print("Failed to create user", err)
                self.loginMessage = "Failed to create user:\(err)"
                return
            }
            
            print("Successfully create user: \(result?.user.uid ?? "")")
            self.loginMessage = "Successfully create user: \(result?.user.uid ?? "")"
            self.persistImageToStorage()
        }
    }
    private func persistImageToStorage() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                os_log("CreatNewAccount")
                self.loginMessage = "Failed to push image to Storage: \(err)"
                return
            }
            
            ref.downloadURL { url, err in
                if let err = err {
                    self.loginMessage = "Failed to retrieve downloadURL: \(err)"
                    return
                }
                
                self.loginMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                guard let url = url else {return}
                self.storeUserInformation(imageProfileUrl: url)
            }
        }
    }
    private func storeUserInformation(imageProfileUrl: URL){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        let userData = ["email":self.email,"uid": uid,"imageProfile": imageProfileUrl.absoluteString]
        FirebaseManager.shared.firestore.collection("user")
            .document(uid).setData(userData) { err in
                if let err = err{
                    print(err)
                    self.loginMessage = ("\(err)")
                    return
                }
                print("successful")
                self.didCompleteLoginProcess()
            }
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login(didCompleteLoginProcess: {
            
        })
    }
}
