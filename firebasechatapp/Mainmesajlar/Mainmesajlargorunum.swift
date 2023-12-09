//
//  Mainmesajlargorunum.swift
//  firebasechatapp
//
//  Created by Selin Avcı on 14.07.2023.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore
import Firebase
import FirebaseFirestoreSwift



class MainMessagesViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var Cikisyapılmasi = false
  // çıkış yapıldığında hesap oluştur kısmına dönmesi
    init() {
        
        DispatchQueue.main.async {
            self.Cikisyapılmasi = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        
      
        fetchCurrentUser()
        fetchRecentMessages()
    }
    
    @Published var recentMessages = [RecentMessage]()
  private var firestoreListener: ListenerRegistration?
    // mesajların firebaseden getirilmesi
   func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
       firestoreListener?.remove()
       self.recentMessages.removeAll()
       
       firestoreListener = FirebaseManager.shared.firestore
           .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Son iletiler getirilemedi: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    let docId = change.document.documentID
                    
                    if let index = self.recentMessages.firstIndex(where: { rm in
                        return rm.id == docId
                    }) {
                        self.recentMessages.remove(at: index)
                    }
                    do {
                
                        if let rm = try? change.document.data(as: RecentMessage.self){
                            self.recentMessages.insert(rm, at: 0)}
                   } catch {      print(error)
                                        }
                 

                })
            }
    }
    
    
    func fetchCurrentUser() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "firebase uid bulunamadı"
            return
        }
        
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }
            
//            self.errorMessage = "123"
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "data bulunamadı"
                return
                
            }
            
            self.chatUser = .init(data : data)

            
        }
    }
    //bunu belki silebilirsin
  //  @Published var Cikisyapılmasi = false
    func handleSignOut(){
        Cikisyapılmasi.toggle()
     try? FirebaseManager.shared.auth.signOut()
    }
}
// main mesajlar görünümğn tasarım ekranı
struct Mainmesajlargorunum: View {
    @State var shouldShowLogOutOptions = false
    @ObservedObject private var vm = MainMessagesViewModel()
    @State var mesajkisminegiris = false
    private var messagesView: some View {
        ScrollView {
            ForEach(vm.recentMessages) { recentMessage in
                VStack {
                   Button {let uid =
                       FirebaseManager.shared.auth.currentUser?.uid == recentMessage.fromId ?
                       recentMessage.toId : recentMessage.fromId
                       self.chatUser = .init(data:[
                        FirebaseConstants.email:
                            recentMessage.email,
                        FirebaseConstants.profileImageUrl:
                            recentMessage.profileImageUrl,
                        FirebaseConstants.uid: uid])
                       self.chatLogViewModel.chatUser = self.chatUser
                       self.chatLogViewModel.fetchMessages()
                       self.mesajkisminegiris.toggle()
                    } label: {
                        
                        HStack(spacing: 16) {
                            WebImage(url: URL(string: recentMessage.profileImageUrl))
                            .resizable()
                            .scaledToFill()
                    
                            .frame(width: 64, height: 64)
                            .clipped()
                            .cornerRadius (64)

                            VStack(alignment: .leading, spacing: 8) {
                                Text(recentMessage.email)
                                    .multilineTextAlignment(.leading)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(#colorLiteral(red: 0.51, green: 0.608, blue: 0.82, alpha: 1)))
                                Text(recentMessage.text)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(#colorLiteral(red: 0.51, green: 0.608, blue: 0.82, alpha: 1)))
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            
                            Text(recentMessage.timeAgo)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(#colorLiteral(red: 0.51, green: 0.608, blue: 0.82, alpha: 1)))
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                }.padding(.horizontal)
                
            }.padding(.bottom, 50)
        }
    }
    private var customNavBar: some View {
        HStack(spacing: 16) {
            WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 44)
                    .stroke(Color(.label), lineWidth: 1)
                )
                .shadow(radius: 5)
            
            
            VStack(alignment: .leading, spacing: 4) {
                let email = vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? ""
                Text(email)
                    .font(.system(size: 24, weight: .bold))
                
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("Aktif")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
                
            }
            
            Spacer()
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(#colorLiteral(red: 0.51, green: 0.608, blue: 0.82, alpha: 1)))
            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Ayarlar"), message: Text("Ne yapmak istersin"), buttons: [
                .destructive(Text("Çıkış Yap"), action: {
                    print("Çıkış başarılı")
                    vm.handleSignOut()
                }),
                .cancel()
            ])
        }
        .fullScreenCover(isPresented: $vm.Cikisyapılmasi, onDismiss: nil){
            Giris_sayfasi(girisislemibitimleri: {
                self.vm.Cikisyapılmasi = false
                self.vm.fetchCurrentUser()
                self.vm.fetchRecentMessages()
             
            })
        }
    }
    private var chatLogViewModel = ChatLogViewModel(chatUser: nil)
    var body: some View {
        NavigationView {
            
            VStack {
                
                customNavBar
                messagesView
                NavigationLink("", isActive:
               $mesajkisminegiris){
                    ChatLogView(vm: chatLogViewModel)
                }
            }
            .overlay(
                newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    
    
    @State var kisisecimleri = false
    
    
    private var newMessageButton: some View {
        Button {
            kisisecimleri.toggle()
        } label: {
            HStack {
                Spacer()
                Text("+ Yeni Mesaj")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
            .background(Color(#colorLiteral(red: 0.51, green: 0.608, blue: 0.82, alpha: 1)))
            .cornerRadius(32)
            .padding(.horizontal)
            .shadow(radius: 15)
        }
        .fullScreenCover(isPresented: $kisisecimleri){
            Yenimesajlarekrani(Yenikullanicisecimi:{ user in
                print(user.email)
                
                self.mesajkisminegiris.toggle()
                self.chatUser = user
                self.chatLogViewModel.chatUser = user
                self.chatLogViewModel.fetchMessages()
            })
            
        }
        
    }
    
    @State var chatUser: ChatUser?
    
    struct Mainmesajlargorunum_Previews: PreviewProvider {
        static var previews: some View {
            Mainmesajlargorunum()
            
        }
    }
}
