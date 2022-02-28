//
//  AccountWindowController.swift
//  handloan
//
//  Created by Mehul Bhavani on 27/02/22.
//

import Cocoa

class AccountWindowController: NSWindowController {
    @IBOutlet private var nameTextField: NSTextField?
    @IBOutlet private var commentsTextField: NSTextField?
    @IBOutlet private var errorLabel: NSTextField?
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    @IBAction func saveButton_Clicked(_ button: NSButton) {
        if let str = nameTextField?.stringValue, str.count > 0 {
            do {
                try Account(name: str, comments: commentsTextField?.stringValue ?? "").save()
                self.window?.sheetParent?.endSheet(self.window!, returnCode: .OK)
            } catch {
                showAlert(withMessageText: "Failed to save account. Please try again", informationText: error.localizedDescription)
            }
        } else {
            showAlert(withMessageText: "Invalid account name!", informationText: "Please try again.")
        }
    }
    @IBAction func cancelButton_Clicked(_ button: NSButton) {
        self.window?.sheetParent?.endSheet(self.window!, returnCode: .cancel)
    }
    
    private func showAlert(withMessageText messageText: String, informationText: String) {
//        let alert = NSAlert()
//        alert.alertStyle = .warning
//        alert.messageText = messageText
//        alert.informativeText = informationText
//        alert.beginSheetModal(for: self.window!, completionHandler: nil)
        errorLabel?.stringValue = messageText + " " + informationText
    }
}
