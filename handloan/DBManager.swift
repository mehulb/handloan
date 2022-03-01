//
//  DBManager.swift
//  handloan
//
//  Created by Mehul Bhavani on 25/02/22.
//

import Foundation
import SQLite

enum DBError: Error {
    case InvalidDatabasePath
    case InvalidDatabaseConnection
}

private let kDatabaseFileName = "handloans.db"

class DBManager {
    private init() {
        do {
            try self.setup()
            Logger.debug("DB ready!")
        } catch {
            Logger.error(error.localizedDescription)
        }
    }
    
    static let shared: DBManager = {
        let obj = DBManager()
        return obj
    }()
    
    private var database: Connection?
    
    func setup() throws {
        do {
            if let dbPath = fetchDatabasePath() {
                let db = try Connection(dbPath)
                
                let accounts = Table("accounts")
                let accId = Expression<String>("id")
                let accName = Expression<String>("name")
                let accComments = Expression<String>("comments")
                try db.run(accounts.create(ifNotExists: true) { t in
                    t.column(accId, primaryKey: true)
                    t.column(accName, unique: true)
                    t.column(accComments, defaultValue: "")
                })
                
                let handloans = Table("handloans")
                let hlId = Expression<String>("id")
                let hlType = Expression<String>("type")
                let hlName = Expression<String>("name")
                let hlDatetime = Expression<Int64>("datetime")
                let hlAmount = Expression<Double>("amount")
                let hlComments = Expression<String>("comments")
                let accountId = Expression<String>("accountId")
                try db.run(handloans.create(ifNotExists: true) { t in
                    t.column(hlId, primaryKey: true)
                    t.column(hlType)
                    t.column(hlName)
                    t.column(hlDatetime)
                    t.column(hlAmount, defaultValue: 0.0)
                    t.column(hlComments, defaultValue: "")
                    t.column(accountId)
                })
                
                let transactions = Table("transactions")
                let tId = Expression<String>("id")
                let tType = Expression<String>("type")
                let tDatetime = Expression<Int64>("datetime")
                let tAmount = Expression<Double>("amount")
                let tComments = Expression<String>("comments")
                let handloadId = Expression<String>("handloanId")
                try db.run(transactions.create(ifNotExists: true) { t in
                    t.column(tId, primaryKey: true)
                    t.column(tType)
                    t.column(tDatetime)
                    t.column(tAmount, defaultValue: 0.0)
                    t.column(tComments, defaultValue: "")
                    t.column(handloadId)
                })
                database = db
            } else {
                throw DBError.InvalidDatabasePath
            }
        } catch {
            throw error
        }
    }
    
    private func fetchDatabasePath() -> String? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if paths.count > 0 {
            var url = URL(fileURLWithPath: paths[0])
            url.appendPathComponent(kDatabaseFileName)
            Logger.debug("DBPath: \(url.path)")
            return url.path
        } else {
            Logger.error("documents dir missing")
        }
        return nil
    }
}

// Manage Accounts (Return Account(s))
extension DBManager {
    func saveAccount(_ a: Account) throws {
        Logger.debug("Add account: \(a.dictionary())")
        if let database = database {
            do {
                let accountsTbl = Table("accounts")
                
                let aidCol = Expression<String>("id")
                let nameCol = Expression<String>("name")
                let commentsCol = Expression<String>("comments")
                
                try database.run(accountsTbl.insert(or: .replace, aidCol <- a.id, nameCol <- a.name, commentsCol <- a.comments))
            } catch {
                throw error
            }
        } else {
            throw DBError.InvalidDatabaseConnection
        }
    }
    func fetchAccounts() throws -> [Account] {
        var accounts = [Account]()
        if let database = database {
            do {
                let accountsTbl = Table("accounts")
                
                let aidCol = Expression<String>("id")
                let nameCol = Expression<String>("name")
                let commentsCol = Expression<String>("comments")
                
                for acc in try database.prepare(accountsTbl) {
                    accounts.append(Account(id: acc[aidCol], name: acc[nameCol], comments: acc[commentsCol]))
                }
                return accounts
            } catch {
                throw error
            }
        } else {
            throw DBError.InvalidDatabaseConnection
        }
    }
    func fetchAccount(forId accountId: String) throws -> Account? {
        return nil
    }
    func fetchAccount(forHandloanId handloanId: String) throws -> Account? {
        return nil
    }
}

// Manage Handloans
extension DBManager {
    func saveHandloan(_ h: Handloan) throws {
        Logger.debug("Add handloan: \(h.dictionary())")
        if let database = database {
            do {
                let handloanTbl = Table("handloans")
                
                let hlIdCol = Expression<String>("id")
                let hlTypeCol = Expression<String>("type")
                let hlNameCol = Expression<String>("name")
                let hlDatetimeCol = Expression<Int64>("datetime")
                let hlAmountCol = Expression<Double>("amount")
                let hlCommentsCol = Expression<String>("comments")
                let accountIdCol = Expression<String>("accountId")
                
                try database.run(handloanTbl.insert(or: .replace, hlIdCol <- h.id, hlTypeCol <- h.type.rawValue, hlNameCol <- h.name, hlDatetimeCol <- Int64(h.datetime), hlAmountCol <- h.amount, hlCommentsCol <- h.comments, accountIdCol <- h.accountId))
            } catch {
                throw error
            }
        } else {
            throw DBError.InvalidDatabaseConnection
        }
    }
    func fetchHandloans(forAccountId accountId: String) throws -> [Handloan] {
        var handloans = [Handloan]()
        if let database = database {
            do {
                let handloanTbl = Table("handloans")
                
                let hlIdCol = Expression<String>("id")
                let hlTypeCol = Expression<String>("type")
                let hlNameCol = Expression<String>("name")
                let hlDatetimeCol = Expression<Int64>("datetime")
                let hlAmountCol = Expression<Double>("amount")
                let hlCommentsCol = Expression<String>("comments")
                let accountIdCol = Expression<String>("accountId")
                
                let accountHandloansTbl = handloanTbl.filter(accountIdCol == accountId)
                for hl in try database.prepare(accountHandloansTbl) {
                    handloans.append(Handloan(id: hl[hlIdCol], type: HandloanType(rawValue: hl[hlTypeCol])!, name: hl[hlNameCol], datetime: TimeInterval(hl[hlDatetimeCol]), amount: hl[hlAmountCol], comments: hl[hlCommentsCol], accountId: hl[accountIdCol]))
                }
                return handloans
            } catch {
                throw error
            }
        } else {
            throw DBError.InvalidDatabaseConnection
        }
    }
    func fetchHandloan(forId handloanId: String) throws -> Handloan? {
        return nil
    }
    func fetchHandloan(forTransactionId transactionId: String) throws -> Handloan? {
        return nil
    }
}

extension DBManager {
    func saveTransaction(_ t: Transaction) throws {
        Logger.debug("Add transaction: \(t.dictionary())")
        if let database = database {
            do {
                let transactionsTbl = Table("transactions")
                
                let tidCol = Expression<String>("id")
                let typeCol = Expression<String>("type")
                let datetimeCol = Expression<Int64>("datetime")
                let amountCol = Expression<Double>("amount")
                let commentsCol = Expression<String?>("comments")
                let handloanIdCol = Expression<String>("handloanId")
                
                try database.run(transactionsTbl.insert(or: .replace, tidCol <- t.id, typeCol <- t.type.rawValue, datetimeCol <- Int64(t.datetime), amountCol <- t.amount, commentsCol <- t.comments, handloanIdCol <- t.handloanId))
            } catch {
                throw error
            }
        } else {
            throw DBError.InvalidDatabaseConnection
        }
    }
    func fetchTransactions(forHandloanId handloanId: String) throws -> [Transaction] {
        var transactions = [Transaction]()
        if let database = database {
            do {
                let transactionsTbl = Table("transactions")
                
                let idCol = Expression<String>("id")
                let typeCol = Expression<String>("type")
                let datetimeCol = Expression<Int64>("datetime")
                let amountCol = Expression<Double>("amount")
                let commentsCol = Expression<String>("comments")
                let handloanIdCol = Expression<String>("handloanId")
                
                let handloanTransactionsTbl = transactionsTbl.filter(handloanIdCol == handloanId)
                for t in try database.prepare(handloanTransactionsTbl) {
                    transactions.append(Transaction(id: t[idCol], type: TransactionType(rawValue: t[typeCol])!, datetime: TimeInterval(t[datetimeCol]), amount: t[amountCol], comments: t[commentsCol], handloanId: t[handloanIdCol]))
                }
                return transactions
            } catch {
                throw error
            }
        } else {
            throw DBError.InvalidDatabaseConnection
        }
    }
    func fetchTransaction(forId transactionId: String) throws -> Transaction? {
        return nil
    }
    func fetchTransaction(forHandloanId handloanId: String) throws -> Transaction? {
        return nil
    }
}

extension DBManager {
    func loadDummyData() {
    do {
        let simon = Account(name: "Simon", comments: "simon says!")
        _ = try DBManager.shared.saveAccount(simon)
        let s_hl_1 = Handloan(type: .borrow, name: "", datetime: "2021-01-18".toDate()!.timeIntervalSince1970, amount: 18000, comments: "Blah Blah", accountId: simon.id)
        _ = try DBManager.shared.saveHandloan(s_hl_1)
        _ = try DBManager.shared.saveTransaction(Transaction(type: .send, datetime: "2021-01-28".toDate()!.timeIntervalSince1970, amount: 10000, comments: "thank you", handloanId: s_hl_1.id))
        _ = try DBManager.shared.saveTransaction(Transaction(type: .send, datetime: "2021-01-30".toDate()!.timeIntervalSince1970, amount: 8000, comments: "thank you again", handloanId: s_hl_1.id))
        
        let s_hl_2 = Handloan(type: .borrow, name: "", datetime: "2021-06-18".toDate()!.timeIntervalSince1970, amount: 35000, comments: "Blah Blah", accountId: simon.id)
        _ = try DBManager.shared.saveHandloan(s_hl_2)
        _ = try DBManager.shared.saveTransaction(Transaction(type: .send, datetime: "2021-07-11".toDate()!.timeIntervalSince1970, amount: 20000, comments: "thank you", handloanId: s_hl_2.id))
        _ = try DBManager.shared.saveTransaction(Transaction(type: .send, datetime: "2021-08-15".toDate()!.timeIntervalSince1970, amount: 10000, comments: "thank you again", handloanId: s_hl_2.id))
        _ = try DBManager.shared.saveTransaction(Transaction(type: .send, datetime: "2021-10-01".toDate()!.timeIntervalSince1970, amount: 3000, comments: "thank you a lot", handloanId: s_hl_2.id))
        
        let adam = Account(name: "Adam", comments: "and eve")
        _ = try DBManager.shared.saveAccount(adam)
        let a_hl_1 = Handloan(type: .lend, name: "", datetime: "2021-11-01".toDate()!.timeIntervalSince1970, amount: 100000, comments: "Lorem Ipsum", accountId: adam.id)
        _ = try DBManager.shared.saveHandloan(a_hl_1)
        _ = try DBManager.shared.saveTransaction(Transaction(type: .receive, datetime: "2021-12-12".toDate()!.timeIntervalSince1970, amount: 20000, comments: "1st installment", handloanId: a_hl_1.id))
        _ = try DBManager.shared.saveTransaction(Transaction(type: .receive, datetime: "2022-01-05".toDate()!.timeIntervalSince1970, amount: 20000, comments: "2st installment", handloanId: a_hl_1.id))
        _ = try DBManager.shared.saveTransaction(Transaction(type: .receive, datetime: "2021-01-30".toDate()!.timeIntervalSince1970, amount: 30000, comments: "3st installment", handloanId: a_hl_1.id))
        
        let kane = Account(name: "Kane", comments: "citizen cane")
        _ = try DBManager.shared.saveAccount(kane)
    } catch {
        Logger.error(error.localizedDescription)
    }
}
}
