//
//  ChatLogView.swift
//  firebasechatapp
//
//  Created by Selin Avcı on 25.07.2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore


//Tanımlamların yapılması
struct FirebaseConstants {
    static let fromId = "fromId"
    static let toId = "toId"
    static let uid = "uid"
    static let text = "text"
    static let profileImageUrl = "profileImageUrl"
    static let email = "email"
    static let recentMessages = "recentMessages"
    static let timestamp = "timestamp"
    static let messages = "messages"
   
}

class ChatLogViewModel : ObservableObject{
    
    @Published var chatText = ""
    @Published var errorMessage=""
    //Nesne oluşturuldu
    @Published var chatMessages = [ChatMessage]()
   
   var chatUser: ChatUser?
  
    //Bu işlem depolanmış olan her özellik için bir başlangıç değeri ayarlamayı ve kullanıma hazır olmadan önce gerekli işlemlerin yapılmasını sağlar.
    init(chatUser: ChatUser?){
        self.chatUser = chatUser
        
        fetchMessages()
    }
    
     var firestoreListener: ListenerRegistration?
    
   //Bu fonksiyon firebase bağlanıp mesaj çekilmesini sağlıyor
    func fetchMessages() {
        
           guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else {return}
           guard let toId = chatUser?.uid else { return }
       self.chatMessages.removeAll()
    //firestoreListener?.remove()
        firestoreListener =  FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
               .document(fromId)
               .collection(toId)
               .order(by: FirebaseConstants.timestamp)
               .addSnapshotListener { querySnapshot, error in
                   if let error = error {
                       self.errorMessage = "Failed to listen for messages: \(error)"
                       print(error)
                       return
                   }
                 self.chatMessages.removeAll()
                   
                   querySnapshot?.documentChanges.forEach({change in
                       if change.type == .added {
                           do{
                               if let cm = try? change.document.data(as:
                                ChatMessage.self){
                                   self.chatMessages.append(cm)
                                   
                                   
                               }
                           }catch{
                               print("Failed\(error)")
                           }
                           
                       }
                       
                   })
                        
                   
                   DispatchQueue.main.async {
                       self.count += 1
                   }
                  
               }
     }
       
//mesajın firestore kayıt edilmesini sağlayan fonksiyon
    func handleSend()
    {
        print(chatText)
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid
        else {return}
         
        guard let toId = chatUser?.uid else{ return }
       
        let document =
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .document()
        
        let msg = ChatMessage(id: nil,fromId: fromId, toId:
                                toId, text: chatText, timestamp: Date())
       try? document.setData(from: msg){ error in
            if let error = error{
                print(error)
                self.errorMessage="Mesajınız Firestore'a kayıt edilemedi\(error)"
                return
            }
            print("Mesajınız Firestore'a başarılı bir şekilde kayıt edildi ")
            self.persistRecentMessages()
            
            self.chatText=""
            self.count += 1
            
        }
        let recipientMessageDocument =
        FirebaseManager.shared.firestore
            .collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        try? recipientMessageDocument.setData(from: msg){ error in
            if let error = error{
                self.errorMessage="Mesajınız Firestore'a kayıt edilemedi\(error)"
                return
            }
         print("Mesajınız Firestore'a başarılı bir şekilde kayıt edildi.")
            
        
        }
    }
    // en son gönderilen mesajın firebase kayıt edilmesi
    private func persistRecentMessages(){
        guard let chatUser = chatUser else { return }
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = self.chatUser?.uid else{return}
           let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
                   .document(uid)
                   .collection(FirebaseConstants.messages)
                   .document(toId)
        let data = [
           // burda sorun var
           FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
           FirebaseConstants.profileImageUrl:
            chatUser.profileImageUrl,
            FirebaseConstants.email: chatUser.email
        ]as [String : Any]

        document.setData(data) { error in
            if let error = error {
                self.errorMessage = "Mesaj kayıt edilirken sorun oluştu: \(error)"
                print(" \(error)")
                return

    }
        }
    }
    @Published var count = 0
    
}
//giriş ekranı tasarımı
struct ChatLogView: View {
    
//    let chatUser: ChatUser?
//
//    init (chatUser: ChatUser?){
//        self.chatUser = chatUser
//        self.vm = .init(chatUser: chatUser )
//    }
    @ObservedObject var vm: ChatLogViewModel
    var body: some View {
        // elemanları üst üste sıralanmasını sağlar
        ZStack {
            messagesView
                        Text(vm.errorMessage)
                    }
        .navigationTitle(vm.chatUser?.email ?? "")
                        .navigationBarTitleDisplayMode(.inline)
                        .onDisappear{
                            vm.firestoreListener?.remove()
                        }

                }
    
     static let emptyScrollToString = "Empty"
    private var messagesView: some View {
            VStack {
                if #available(iOS 15.0, *) {
                    ScrollView {
                        ScrollViewReader{ ScrollViewProxy in
                            VStack{
                                ForEach(vm.chatMessages) { message in
                                    MessageView(message: message)
                                }
                                    HStack{ Spacer() }
                                        .id(Self.emptyScrollToString)
                                
                                
                            }.onReceive(vm.$count) { _ in
                    withAnimation(.easeOut(duration: 0.5)) {
                        //burda bir sorun olabilir
                      ScrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                                                   }
                                               }
                                           }
                                       }
                    .background(Color(.init(white: 0.95, alpha: 1)))
                    .safeAreaInset(edge: .bottom) {
                       
                        chatBottomBar
                    .background(Color(.systemBackground).ignoresSafeArea())
                        //DescriptionPlaceholder()
                    }
                } else {
                   
                }
            }
        }
        
    
    private var chatBottomBar: some View {
        
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(#colorLiteral(red: 0.51, green: 0.608, blue: 0.82, alpha: 1)))
            ZStack {
                DescriptionPlaceholder()
                TextEditor(text: $vm.chatText)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1)
                   
            }
            .frame(height: 40)
            
            Button {
                vm.handleSend()
                vm.fetchMessages()
       
                
            } label: {
                Text("Gönder")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(#colorLiteral(red: 0.51, green: 0.608, blue: 0.82, alpha: 1)))
            .cornerRadius(40)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
struct MessageView: View{
    let message: ChatMessage
    var body: some View{
        //dikey bir şekilde sıralanmasını sağlıyor
        VStack {
            if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                HStack {
                    Spacer()
                    HStack {
                        Text(message.text)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color(#colorLiteral(red: 0.51, green: 0.608, blue: 0.82, alpha: 1)))
                    .cornerRadius(14)
                }
            } else {
                //yatay bir şekilde sıralanmasını sağlıyor
                HStack {
                    HStack {
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
        .padding(.top, 8)
        
    }
}
//Alttaki mesajlaşma yerinin tasarımı
private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Açıklama")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}
    



struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        Mainmesajlargorunum()
    }
}
