//
//  ViewController.swift
//  handloan
//
//  Created by Mehul Bhavani on 25/02/22.
//

import Cocoa

enum ListError: Error {
    case AccountMissing
    case HandloanMissing
    case TransactionMissing
    case DataMissing
}

class ViewController: NSViewController {
    @IBOutlet private var outlineView: NSOutlineView?
    @IBOutlet private var messageBox: NSBox?
    @IBOutlet private var balanceLabel: NSTextField?
    
    var account: Account?
    private var handloans = [Handloan]()
    private var transactions = [String: [Transaction]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightClickMenu = NSMenu()
        rightClickMenu.addItem(withTitle: "Edit", action: #selector(editMenuItem_Clicked(_:)), keyEquivalent: "")
        rightClickMenu.addItem(withTitle: "Delete", action: #selector(deleteMenuItem_Clicked(_:)), keyEquivalent: "")
        outlineView?.menu = rightClickMenu
        outlineView?.menu?.delegate = self
        
        reload()
        
        NotificationCenter.default.addObserver(forName: .reload, object: nil, queue: nil) { _ in
            self.reload()
        }
        NotificationCenter.default.addObserver(forName: .selectAccount, object: nil, queue: nil) { note in
            if let account = note.object as? Account {
                self.account = account
                self.reload()
            }
        }
    }
    func reload() {
        do {
            if let account = account {
                handloans = try account.handloans()
                for h in handloans {
                    let tes = try h.transactions()
                    transactions[h.id] = tes
                }
            }
        } catch {
            Logger.error(error.localizedDescription)
        }
        messageBox?.isHidden = handloans.count > 0
        outlineView?.reloadData()
        
        if let balance = account?.balance() {
            balanceLabel?.stringValue = balance.currencyFormat()
        }
    }
    func calculateBalance(_ handloan: Handloan) -> Double {
        let total = handloan.amount
        var amount = 0.0
        if let tes = transactions[handloan.id] {
            for t in tes {
                amount += t.amount
            }
        }
        return total-amount
    }
}
extension ViewController: NSMenuDelegate {
    @objc func editMenuItem_Clicked(_ sender: Any) {
        
    }
    @objc func deleteMenuItem_Clicked(_ sender: Any) {
        
    }
    func menuWillOpen(_ menu: NSMenu) {
        if let row = outlineView?.selectedRow, row < 0 {
            menu.cancelTrackingWithoutAnimation()
        }
    }
}

extension ViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return handloans.count
        }
        else if let h = item as? Handloan {
            if let tes = transactions[h.id] {
                return tes.count
            }
        }
        return 0
    }
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return handloans[index]
        } else if let h = item as? Handloan {
            if let tes = transactions[h.id] {
                return tes[index]
            }
        }
        return ListError.DataMissing
    }
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let h = item as? Handloan {
            return h.hasTransactions()
        }
        return false
    }
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return item
    }
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return (item is Handloan) ? 28.0 : 17.0
    }
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "kCell"), owner: self) as? NSTableCellView {
            if let handloan = item as? Handloan {
                cell.textField?.font = NSFont.systemFont(ofSize: 13.0, weight: .bold)
                if tableColumn?.identifier.rawValue == "kTypeID" {
                    cell.textField?.stringValue = handloan.type.rawValue
                } else if tableColumn?.identifier.rawValue == "kNameID" {
                    cell.textField?.stringValue = handloan.name
                } else if tableColumn?.identifier.rawValue == "kDateID" {
                    cell.textField?.stringValue = "\(Date(timeIntervalSince1970: handloan.datetime).toFormat("dd MMM yyyy"))"
                } else if tableColumn?.identifier.rawValue == "kAmountID" {
                    cell.textField?.stringValue = handloan.amount.currencyFormat()
                    cell.textField?.font = NSFont(name: "Andale Mono", size: 13.0)
                    cell.textField?.alignment = .right
                } else if tableColumn?.identifier.rawValue == "kBalanceID" {
                    if let balance = handloan.balance() {
                        cell.textField?.stringValue = balance.currencyFormat()
                        if balance != 0.0 {
                            cell.textField?.textColor = handloan.type == .borrow ? NSColor.systemRed : NSColor.systemGreen
                        } else {
                            cell.textField?.textColor = NSColor.labelColor
                        }
                        cell.textField?.alignment = .right
                    } else {
                        cell.textField?.stringValue = "#err"
                        cell.textField?.textColor = .systemYellow
                    }
                    cell.textField?.font = NSFont(name: "Andale Mono", size: 13.0)
                } else if tableColumn?.identifier.rawValue == "kCommentsID" {
                    cell.textField?.stringValue = handloan.comments
                }
                return cell;
            } else if let transaction = item as? Transaction {
                cell.textField?.font = NSFont.systemFont(ofSize: 12.0, weight: .regular)
                if tableColumn?.identifier.rawValue == "kTypeID" {
                    cell.textField?.stringValue = transaction.type.rawValue
                } else if tableColumn?.identifier.rawValue == "kNameID" {
                    cell.textField?.stringValue = ""
                } else if tableColumn?.identifier.rawValue == "kDateID" {
                    cell.textField?.stringValue = "\(Date(timeIntervalSince1970: transaction.datetime).toFormat("dd MMM yyyy"))"
                } else if tableColumn?.identifier.rawValue == "kAmountID" {
                    cell.textField?.stringValue = transaction.amount.currencyFormat()
                    cell.textField?.alignment = .right
                    cell.textField?.font = NSFont(name: "Andale Mono", size: 12.0)
                } else if tableColumn?.identifier.rawValue == "kBalanceID" {
                    cell.textField?.stringValue = ""
                    cell.textField?.alignment = .right
                } else if tableColumn?.identifier.rawValue == "kCommentsID" {
                    cell.textField?.stringValue = transaction.comments
                }
                return cell;
            } else if let err = item as? ListError {
                cell.textField?.stringValue = err.localizedDescription
                return cell;
            }
        }
        return nil;
    }
    func outlineViewSelectionDidChange(_ notification: Notification) {
        if let index = outlineView?.selectedRow, index >= 0 {
            let item = outlineView?.item(atRow: index)
            if let h = item as? Handloan {
                Context.current.handloan = h
            } else if let t = item as? Transaction {
                Context.current.transaction = t
            }
        }
    }
}
