//
//  SideViewController.swift
//  handloan
//
//  Created by Mehul Bhavani on 25/02/22.
//

import Cocoa

class SideViewController: NSViewController {
    @IBOutlet private var tableView: NSTableView?
    
    var accounts = [Account]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        DBManager.shared.loadDummyData()
        
        let rightClickMenu = NSMenu()
        rightClickMenu.addItem(withTitle: "Edit", action: #selector(editMenuItem_Clicked(_:)), keyEquivalent: "")
        rightClickMenu.addItem(withTitle: "Delete", action: #selector(deleteMenuItem_Clicked(_:)), keyEquivalent: "")
        tableView?.menu = rightClickMenu
        tableView?.menu?.delegate = self
        
        reload()
        if let selectedRow = tableView?.selectedRow, selectedRow >= 0 {
            Context.current.account = accounts[selectedRow]
            NotificationCenter.default.post(name: .selectAccount, object: accounts[selectedRow])
        }
        
        NotificationCenter.default.addObserver(forName: .reload, object: nil, queue: nil) { _ in
            self.reload()
        }
    }
    
    func reload() {
        do {
            accounts = try Account.all()
        } catch {
            Logger.error(error)
        }
        tableView?.reloadData()
    }
    
}
extension SideViewController: NSMenuDelegate {
    @objc func editMenuItem_Clicked(_ sender: Any) {
        
    }
    @objc func deleteMenuItem_Clicked(_ sender: Any) {
        
    }
    func menuWillOpen(_ menu: NSMenu) {
        if let row = tableView?.selectedRow, row < 0 {
            menu.cancelTrackingWithoutAnimation()
        }
    }
}

extension SideViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return accounts.count
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView {
            let account = accounts[row]
            if tableColumn?.identifier.rawValue == "kNameID" {
                cell.textField?.stringValue = account.name
            }
            return cell;
        }
        return nil;
    }
    func tableViewSelectionDidChange(_ notification: Notification) {
        Logger.debug()
        if let selectedRow = tableView?.selectedRow, selectedRow >= 0 {
            Context.current.account = accounts[selectedRow]
            NotificationCenter.default.post(name: .selectAccount, object: accounts[selectedRow])
        }
    }
}
