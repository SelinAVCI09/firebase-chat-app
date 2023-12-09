//
//  firebasechatappApp.swift
//  firebasechatapp
//
//  Created by Selin Avcı on 3.07.2023.
//


import SwiftUI
import FirebaseCore
import Firebase
import Firebase

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       FirebaseApp.configure()      
        return true
    }
}

@main
struct firebasechatappApp: App {
   @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
   
    var body: some Scene {
        WindowGroup {
            Mainmesajlargorunum()
        }
    }
}
