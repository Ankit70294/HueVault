//
//  HueVaultApp.swift
//  HueVault
//
//  Created by Ankit Singh on 28/07/25.
//

import SwiftUI
import FirebaseCore

@main
struct HueVaultApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
    }
}
