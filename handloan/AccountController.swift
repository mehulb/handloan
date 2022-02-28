//
//  AccountController.swift
//  handloan
//
//  Created by Mehul Bhavani on 26/02/22.
//

import Cocoa

class AccountWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

}

class AccountViewController: NSViewController {
    @IBOutlet private var nameTextField: NSTextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func saveButton_Clicked(_ button: NSButton) {
        if let str = nameTextField?.stringValue, str.count > 0 {
            do {
                try DBManager.shared.addAccount(Account(name: str))
                self.view.window?.sheetParent?.endSheet(self.view.window!, returnCode: .OK)
            } catch {
                showAlert(withMessageText: "Failed to save account. Please try again", informationText: error.localizedDescription)
            }
        } else {
            showAlert(withMessageText: "Invalid account name!", informationText: "Please try again.")
        }
    }
    @IBAction func cancelButton_Clicked(_ button: NSButton) {
        self.view.window?.sheetParent?.endSheet(self.view.window!, returnCode: .cancel)
    }
    
    private func showAlert(withMessageText messageText: String, informationText: String) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = messageText
        alert.informativeText = informationText
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
}
