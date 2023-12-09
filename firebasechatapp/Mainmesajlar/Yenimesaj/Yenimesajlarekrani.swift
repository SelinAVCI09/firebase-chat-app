//
//  Yenimesajlarekrani.swift
//  firebasechatapp
//
//  Created by Selin Avcı on 21.07.2023.
//

import SwiftUI
import SDWebImageSwiftUI
class CreateNewMessageViewModel: ObservableObject {
    
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    
    init() {
        fetchAllUsers()
    }
   // firebaseden kullanıcıların çekilmesi
    private func fetchAllUsers() {
        FirebaseManager.shared.firestore.collection("users")
            .getDocuments { documentsSnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch users: \(error)"
                    print("Failed to fetch users: \(error)")
                    return
                }
                
                documentsSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    let user = ChatUser(data: data)
                    if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
                        self.users.append(.init(data: data))
                    }
                    
                })
            }
    }
}
// yeni mesaj gönderme ekranının tasarımı
struct Yenimesajlarekrani: View {
    
    
    let Yenikullanicisecimi: (ChatUser)->()
    
    @Environment(\.presentationMode) var presentationMode
      
      @ObservedObject var vm = CreateNewMessageViewModel()
    var body: some View {
        NavigationView{
            ScrollView{
                
                ForEach(vm.users) { user in
                    
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        Yenikullanicisecimi(user)
                    } label: {
                        HStack(spacing: 16) {
                            WebImage(url: URL(string: user.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(45)
                                .overlay(RoundedRectangle(cornerRadius: 44)
                                            .stroke(Color(.label), lineWidth: 1)
                                )
                                .shadow(radius: 5)
                                
                            Text(user.email)
                                .foregroundColor(Color(.label))
                            Spacer()
                        }.padding(.horizontal)
                    }
                    Divider()
                        .padding(.vertical, 8)
                    
                    
                }

                }.navigationTitle("Yeni Mesaj Gönder")
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Text("Geri")
                            }
                        }
                        
                    }}
        }
    }


struct Yenimesajlarekrani_Previews: PreviewProvider {
    static var previews: some View {
        Mainmesajlargorunum()
    }
}
