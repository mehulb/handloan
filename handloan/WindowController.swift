//
//  WindowController.swift
//  handloan
//
//  Created by Mehul Bhavani on 25/02/22.
//

import Cocoa
import SwiftDate

extension Notification.Name {
    static let reload = Notification.Name("reload")
    static let selectAccount = Notification.Name("selectAccount")
}

class WindowController: NSWindowController {
    private weak var accountWindowController: AccountWindowController?
    private weak var handloanWindowController: HandloanWindowController?
    private weak var transactionWindowController: TransactionWindowController?
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    @IBAction func addAccountBarButton_Clicked(_ button: NSButton) {
        Logger.debug()
        if accountWindowController == nil {
            let windowController = AccountWindowController(windowNibName: "AccountWindowController")
            accountWindowController = windowController
            self.window?.beginSheet(windowController.window!, completionHandler: { response in
                Logger.debug("\(response)")
                if response == .OK {
                    //self.reload()
                }
            })
        }
        if let windowController = accountWindowController {
            self.window?.beginSheet(windowController.window!, completionHandler: { response in
                Logger.debug("\(response)")
                if response == .OK {
                    //self.reload()
                }
            })
        }
    }
    @IBAction func addHandloanBarButton_Clicked(_ button: NSButton) {
        Logger.debug()
        if handloanWindowController == nil {
            let windowController = HandloanWindowController(windowNibName: "HandloanWindowController")
            handloanWindowController = windowController
            self.window?.beginSheet(windowController.window!, completionHandler: { response in
                Logger.debug("\(response)")
                if response == .OK {
                    //self.reload()
                }
            })
        }
        if let windowController = handloanWindowController {
            self.window?.beginSheet(windowController.window!, completionHandler: { response in
                Logger.debug("\(response)")
                if response == .OK {
                    self.reload()
                }
            })
        }
    }
    @IBAction func addTransactionBarButton_Clicked(_ button: NSButton) {
        Logger.debug()
        if transactionWindowController == nil {
            let windowController = TransactionWindowController(windowNibName: "TransactionWindowController")
            transactionWindowController = windowController
            self.window?.beginSheet(windowController.window!, completionHandler: { response in
                Logger.debug("\(response)")
                if response == .OK {
                    self.reload()
                }
            })
        }
        if let windowController = transactionWindowController {
            self.window?.beginSheet(windowController.window!, completionHandler: { response in
                Logger.debug("\(response)")
                if response == .OK {
                    self.reload()
                }
            })
        }
    }
    @IBAction func reloadBarButton_Clicked(_ button: NSButton) {
        Logger.debug()
        reload()
    }
    
    private func reload() {
        NotificationCenter.default.post(name: .reload, object: nil)
    }
}
class Window: NSWindow {
    override class func awakeFromNib() {}
}
class SplitViewController: NSSplitViewController {
    override class func awakeFromNib() {}
}
