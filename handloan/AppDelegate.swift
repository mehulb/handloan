//
//  AppDelegate.swift
//  handloan
//
//  Created by Mehul Bhavani on 25/02/22.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

extension AppDelegate {
    @IBAction func openDatabaseDirectory(_ item: Any) {
        if let path = DBManager.shared.fetchDatabasePath() {
            let url = URL(fileURLWithPath: path).deletingLastPathComponent()
            NSWorkspace.shared.open(url)
        }
        
    }
}

