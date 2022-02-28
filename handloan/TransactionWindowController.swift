//
//  TransactionWindowController.swift
//  handloan
//
//  Created by Mehul Bhavani on 27/02/22.
//

import Cocoa

class TransactionWindowController: NSWindowController {
    
    var account: Account?
    var handloan: Handloan?
    
    @IBOutlet private var accountLabel: NSTextField?
    @IBOutlet private var handloanAmountLabel: NSTextField?
    @IBOutlet private var typeSegemtedControl: NSSegmentedControl?
    @IBOutlet private var datePicker: NSDatePicker?
    @IBOutlet private var amountTextField: NSTextField?
    @IBOutlet private var commentsTextField: NSTextField?
    @IBOutlet private var errorLabel: NSTextField?

    override func windowDidLoad() {
        super.windowDidLoad()
        
        if account == nil {
            errorLabel?.stringValue = "Account data missing!"
        }
        if handloan == nil {
            errorLabel?.stringValue = "Handloan data missing!"
        }
        
        accountLabel?.stringValue = account?.name ?? "<<error>>"
        handloanAmountLabel?.stringValue = handloan == nil ? "<<error>>" : "\(handloan?.amount ?? 0.0)"
        typeSegemtedControl?.selectSegment(withTag: 1)
        datePicker?.dateValue = Date()
        amountTextField?.doubleValue = 0.0
        commentsTextField?.stringValue = ""
        errorLabel?.stringValue = ""
    }
    
    @IBAction func saveButton_Clicked(_ button: NSButton) {
        if let handloan = handloan, let datetime = datePicker?.dateValue.timeIntervalSince1970, let amount = amountTextField?.doubleValue, let comments = commentsTextField?.stringValue {
            let t = Transaction(type: typeSegemtedControl?.selectedSegment == 0 ? .send : .receive, datetime: datetime, amount: amount, comments: comments, handloanId: handloan.id)
            do {
                try t.save()
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
    
    private func showAlert(withMessageText messageText: String, informationText: String) {
        //        let alert = NSAlert()
        //        alert.alertStyle = .warning
        //        alert.messageText = messageText
        //        alert.informativeText = informationText
        //        alert.beginSheetModal(for: self.window!, completionHandler: nil)
        errorLabel?.stringValue = messageText + " " + informationText
    }
}
