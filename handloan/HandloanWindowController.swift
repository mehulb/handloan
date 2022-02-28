//
//  HandloanWindowController.swift
//  handloan
//
//  Created by Mehul Bhavani on 27/02/22.
//

import Cocoa

class HandloanWindowController: NSWindowController {
    
    @IBOutlet private var accountLabel: NSTextField?
    @IBOutlet private var typeSegemtedControl: NSSegmentedControl?
    @IBOutlet private var nameTextField: NSTextField?
    @IBOutlet private var datePicker: NSDatePicker?
    @IBOutlet private var amountTextField: NSTextField?
    @IBOutlet private var commentsTextField: NSTextField?
    @IBOutlet private var errorLabel: NSTextField?
    
    var account: Account?

    override func windowDidLoad() {
        super.windowDidLoad()
        
        if account == nil {
            errorLabel?.stringValue = "Account data missing!"
        }
        
        accountLabel?.stringValue = account?.name ?? "<<error>>"
        typeSegemtedControl?.selectSegment(withTag: 1)
        datePicker?.dateValue = Date()
        amountTextField?.doubleValue = 0.0
        commentsTextField?.stringValue = ""
        errorLabel?.stringValue = ""
    }
    
    @IBAction func saveButton_Clicked(_ button: NSButton) {
        if let account = account, let datetime = datePicker?.dateValue.timeIntervalSince1970, let amount = amountTextField?.doubleValue, let comments = commentsTextField?.stringValue, let name = nameTextField?.stringValue {
            let hl = Handloan(type: typeSegemtedControl?.selectedSegment == 0 ? .borrow : .lend, name: name, datetime: datetime, amount: amount, comments: comments, accountId: account.id)
            do {
                try hl.save()
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
    
    private func showAlert(withMessageText messageText: String, informationText: String) {
        //        let alert = NSAlert()
        //        alert.alertStyle = .warning
        //        alert.messageText = messageText
        //        alert.informativeText = informationText
        //        alert.beginSheetModal(for: self.window!, completionHandler: nil)
        errorLabel?.stringValue = messageText + " " + informationText
    }
}
