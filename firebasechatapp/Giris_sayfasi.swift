//
//  ContentView.swift
//  firebasechatapp
//
//  Created by Selin Avcı on 3.07.2023.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseStorage
//import FirebaseFirestore
//import FirebaseSharedSwift



struct Giris_sayfasi: View {
    
    
    let girisislemibitimleri:() -> ()
    // değişkenlerin oluşturulması
    @State private  var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
   
    
     @State var shouldShowImagePicker = false
    var body: some View {
        NavigationView {
            ScrollView {
                // giriş ekranındaki slider
                VStack(spacing: 16) {
                    Picker(selection: $isLoginMode, label: Text("seç")) {
                        Text("Giriş Yap")
                            
                            .tag(true)
                        Text("Hesap Oluştur")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                        
                    
                    if !isLoginMode {
                        Button {
//                            butonun tıklanabilir olmasını sağlıyor
                            shouldShowImagePicker.toggle()
                        }label: {
                        
                        
                        VStack {
                            if let image = self.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 128, height: 128)
                                    .cornerRadius(64)
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 64))
                                    .padding()
                                    .foregroundColor(Color(#colorLiteral(red: 0.51, green: 0.608, blue: 0.82, alpha: 1)) )
                            }
                        }
                        .overlay(RoundedRectangle(cornerRadius: 64)
                                    .stroke(Color(#colorLiteral(red: 0.51, green: 0.608, blue: 0.82, alpha: 1)), lineWidth: 3)
                        )
                        
                    }
                }
                            
                       
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Şifre", text: $password)
                    }
                    .padding(12)
                    .background(Color.white)
                    
                    Button {
                        //bu buton tıklandığında hesabına giriş yapılıyor eğer başka buton tıklanırsa (zaten iki tane buton var)
                       // hesap oluşturuluyor
                        handleAction()
                    } label: {
                        HStack {
                            Spacer()
                            Text(isLoginMode ? "Giriş yap" : "Hesap Oluştur")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }.background(Color(#colorLiteral(red: 0.51, green: 0.608, blue: 0.82, alpha: 1)))
                        
                    }
                    Text(self.loginStatusMessage )
                        .foregroundColor(.red)
                }
                .padding()
                
            }
            .navigationTitle(isLoginMode ? "Giriş yap" : "Hesap Oluştur")
            .background(Color(.init(white: 0, alpha: 0.05))
                .ignoresSafeArea())
        }.navigationViewStyle(StackNavigationViewStyle())
            .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
                ImagePicker(image: $image)
            }
    }
    @State var image: UIImage?
    private func handleAction() {
        if isLoginMode {
          loginUser()
        } else {
            yenihesapolustur()
        }
    }
    //Giriş yapılması şifre ve user name kontrolleri
    private func loginUser(){
        
        Auth.auth().signIn(withEmail: email, password: password){
             result, err in
            if let err=err {
                print("Olmadı",err)
                self.loginStatusMessage = "Giriş yapılırken sorun oluştu: \(err) "
      
                return}
            print("başarılı")
            self.loginStatusMessage = "Başarılı bir şekilde giriş yapıldı : \(result?.user.uid ?? "")"
           
            self.girisislemibitimleri()
        }
    }
    @State var loginStatusMessage=""
    //yeni hesap oluştulması
  private func  yenihesapolustur(){
      
      if self.image == nil{
          self.loginStatusMessage = "Kullanıcı profil fotoğrafı seçmelisiniz "
          return
      }
      
      Auth.auth().createUser(withEmail: email, password: password){
      result, err in
          if let err=err {
              print("Hata var",err)
              self.loginStatusMessage = "Hesap oluşturulurken sorun oluştu: \(err) "
    
              return}
          print("başarılı")
          self.loginStatusMessage = "Başarılı bir şekilde hesap oluşturuldu : \(result?.user.uid ?? "")"
          self.persistImageToStorage()
          
      }
    }
    //galeriden resimlerin seçilmesi
    private func persistImageToStorage(){
        //    let filename = UUID().uuidString
                guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
                let ref = FirebaseManager.shared.storage.reference(withPath: uid)
                guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
                ref.putData(imageData, metadata: nil) { metadata, err in
                    if let err = err {
                        self.loginStatusMessage = "Storage e fotoğraf kayıt edilmedi: \(err)"
                        return
                    }
                    
                    ref.downloadURL { url, err in
                        if let err = err {
                            self.loginStatusMessage = "Failed to retrieve downloadURL: \(err)"
                            return
                        }
                        
                        self.loginStatusMessage = "Başarılı.Stored image urlsi: \(url?.absoluteString ?? "")"
                      print(url?.absoluteString)
                     
                        guard let url = url else{return}
                     
                        self.storeUserInformation(imageProfileUrl: url)
                        
                        
                    }
                }
            }
    //firabase kayıt edilmesi
    private func storeUserInformation(imageProfileUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = ["email": self.email, "uid": uid, "profileImageUrl": imageProfileUrl.absoluteString]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { err in
                if let err = err {
                    print(err)
                    self.loginStatusMessage = "\(err)"
                    return
                }
                
                print("Başarılı")
                self.girisislemibitimleri()
            }
    }
}
    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Giris_sayfasi(girisislemibitimleri:{})
    }
}
