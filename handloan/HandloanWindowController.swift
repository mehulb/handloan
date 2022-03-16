//
//  HandloanWindowController.swift
//  handloan
//
//  Created by Mehul Bhavani on 27/02/22.
//

import Cocoa

class HandloanWindowController: NSWindowController {
    
    @IBOutlet private var accountsPopUpButton: NSPopUpButton?
    @IBOutlet private var typeSegemtedControl: NSSegmentedControl?
    @IBOutlet private var nameTextField: NSTextField?
    @IBOutlet private var datePicker: NSDatePicker?
    @IBOutlet private var amountTextField: NSTextField?
    @IBOutlet private var commentsTextField: NSTextField?
    @IBOutlet private var errorLabel: NSTextField?
    
    private var currentAccount: Account?
    private var accounts: [Account]?

    override func windowDidLoad() {
        super.windowDidLoad()
        do {
            accounts = try Account.all()
            accountsPopUpButton?.removeAllItems()
            if let accounts = accounts {
                for a in accounts {
                    accountsPopUpButton?.addItem(withTitle: a.name)
                }
            }
            if let a = Context.current.account {
                currentAccount = a
            } else {
                currentAccount = accounts?.first
            }
        } catch {
            Logger.error(error.localizedDescription)
            errorLabel?.stringValue = error.localizedDescription
        }
        
        if let currentAccount = currentAccount {
            accountsPopUpButton?.selectItem(withTitle: currentAccount.name)
        }
        typeSegemtedControl?.selectSegment(withTag: 1)
        datePicker?.dateValue = Date()
        amountTextField?.stringValue = ""
        commentsTextField?.stringValue = ""
        errorLabel?.stringValue = ""
    }
    
    @IBAction func saveButton_Clicked(_ button: NSButton) {
        if let account = currentAccount,
           let datetime = datePicker?.dateValue.timeIntervalSince1970,
           let amount = amountTextField?.doubleValue,
           let comments = commentsTextField?.stringValue,
           let name = nameTextField?.stringValue {
            let hl = Handloan(type: typeSegemtedControl?.selectedSegment == 0 ? .borrow : .lend, name: name, datetime: datetime, amount: amount, comments: comments, accountId: account.id)
            do {
                try hl.save()
                self.window?.sheetParent?.endSheet(self.window!, returnCode: .OK)
            } catch {
                showAlert(withMessageText: "Failed to save handloan.", informationText: error.localizedDescription)
            }
        } else {
            showAlert(withMessageText: "Failed to save handloan.", informationText: "Invalid argument(s).")
        }
    }
    @IBAction func cancelButton_Clicked(_ button: NSButton) {
        self.window?.sheetParent?.endSheet(self.window!, returnCode: .cancel)
    }
    @IBAction func accountsPopUpButton_SelectionChanged(_ button: NSPopUpButton) {
        Logger.debug(button.selectedItem?.title)
        if let accounts = accounts {
            currentAccount = accounts[button.indexOfSelectedItem]
        }
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
