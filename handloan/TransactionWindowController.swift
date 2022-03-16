//
//  TransactionWindowController.swift
//  handloan
//
//  Created by Mehul Bhavani on 27/02/22.
//

import Cocoa

class TransactionWindowController: NSWindowController {
    
    @IBOutlet private var accountsPopUpButton: NSPopUpButton?
    @IBOutlet private var handloansPopUpButton: NSPopUpButton?
    @IBOutlet private var typeSegemtedControl: NSSegmentedControl?
    @IBOutlet private var datePicker: NSDatePicker?
    @IBOutlet private var amountTextField: NSTextField?
    @IBOutlet private var commentsTextField: NSTextField?
    @IBOutlet private var errorLabel: NSTextField?
    
    private var currentAccount: Account?
    private var accounts: [Account]?
    private var currentHandloan: Handloan?
    private var handloans: [Handloan]?

    override func windowDidLoad() {
        super.windowDidLoad()
        
        do {
            accounts = try Account.all()
            if let a = Context.current.account {
                currentAccount = a
            } else {
                currentAccount = accounts?.first
            }
            
            handloans = try currentAccount?.handloans()
            if let h = Context.current.handloan {
                currentHandloan = h
            } else {
                currentHandloan = handloans?.first
            }
        } catch {
            Logger.error(error.localizedDescription)
            showAlert(withMessageText: error.localizedDescription, informationText: "")
        }
        
        updateUI()
    }
    
    @IBAction func saveButton_Clicked(_ button: NSButton) {
        if let handloan = currentHandloan,
           let datetime = datePicker?.dateValue.timeIntervalSince1970,
           let amount = amountTextField?.doubleValue,
           let comments = commentsTextField?.stringValue {
            let t = Transaction(type: typeSegemtedControl?.selectedSegment == 0 ? .send : .receive, datetime: datetime, amount: amount, comments: comments, handloanId: handloan.id)
            do {
                try t.save()
                self.window?.sheetParent?.endSheet(self.window!, returnCode: .OK)
            } catch {
                showAlert(withMessageText: "Failed to save transaction.", informationText: error.localizedDescription)
            }
        } else {
            showAlert(withMessageText: "Failed to save transaction.", informationText: "Invalid argument(s).")
        }
    }
    @IBAction func cancelButton_Clicked(_ button: NSButton) {
        self.window?.sheetParent?.endSheet(self.window!, returnCode: .cancel)
    }
    @IBAction func accountsPopUpButton_SelectionChanged(_ button: NSPopUpButton) {
        Logger.debug(button.selectedItem?.title)
        if let accounts = accounts {
            currentAccount = accounts[button.indexOfSelectedItem]
            do {
                handloans = try currentAccount?.handloans()
                currentHandloan = handloans?.first
                updateUI()
            } catch {
                showAlert(withMessageText: "Failed to load handloans.", informationText: error.localizedDescription)
            }
        }
    }
    @IBAction func handloansPopUpButton_SelectionChanged(_ button: NSPopUpButton) {
        Logger.debug(button.selectedItem?.title)
        if let handloans = handloans {
            currentHandloan = handloans[button.indexOfSelectedItem]
            if let currentHandloan = currentHandloan {
                typeSegemtedControl?.selectSegment(withTag: currentHandloan.type == .borrow ? 0 : 1)
            }
        }
    }
    
    private func updateUI() {
        accountsPopUpButton?.removeAllItems()
        if let accounts = accounts {
            for a in accounts {
                accountsPopUpButton?.addItem(withTitle: a.name)
            }
        }
        handloansPopUpButton?.removeAllItems()
        if let handloans = handloans {
            for h in handloans {
                handloansPopUpButton?.addItem(withTitle: "\(h.name)[\(h.amount)][\(h.type.rawValue)]")
            }
        }
        if let currentAccount = currentAccount {
            accountsPopUpButton?.selectItem(withTitle: currentAccount.name)
        }
        if let currentHandloan = currentHandloan {
            handloansPopUpButton?.selectItem(withTitle: "\(currentHandloan.name)[\(currentHandloan.amount)][\(currentHandloan.type.rawValue)]")
            typeSegemtedControl?.selectSegment(withTag: currentHandloan.type == .borrow ? 0 : 1)
        }
        
        datePicker?.dateValue = Date()
        amountTextField?.stringValue = ""
        commentsTextField?.stringValue = ""
        errorLabel?.stringValue = ""
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
