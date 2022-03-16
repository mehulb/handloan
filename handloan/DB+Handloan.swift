//
//  DB+Handloan.swift
//  handloan
//
//  Created by Mehul Bhavani on 02/03/22.
//

import Foundation
import SQLite

extension DBManager {
    fileprivate func saveHandloan(_ h: Handloan) throws {
        Logger.debug("Add handloan: \(h.dictionary())")
        if let database = database {
            do {
                let handloanTbl = Table("handloans")
                
                let idCol = Expression<String>("id")
                let typeCol = Expression<String>("type")
                let nameCol = Expression<String>("name")
                let datetimeCol = Expression<Int64>("datetime")
                let amountCol = Expression<Double>("amount")
                let commentsCol = Expression<String>("comments")
                let accountIdCol = Expression<String>("accountId")
                
                try database.run(handloanTbl.insert(or: .replace, idCol <- h.id, typeCol <- h.type.rawValue, nameCol <- h.name, datetimeCol <- Int64(h.datetime), amountCol <- h.amount, commentsCol <- h.comments, accountIdCol <- h.accountId))
            } catch {
                throw error
            }
        } else {
            throw DBError.InvalidDatabaseConnection
        }
    }
    fileprivate func fetchHandloan(forId handloanId: String) throws -> Handloan? {
        if let database = database {
            do {
                let handloanTbl = Table("handloans")
                
                let idCol = Expression<String>("id")
                let typeCol = Expression<String>("type")
                let nameCol = Expression<String>("name")
                let datetimeCol = Expression<Int64>("datetime")
                let amountCol = Expression<Double>("amount")
                let commentsCol = Expression<String>("comments")
                let accountIdCol = Expression<String>("accountId")
                
                let filteredTbl = handloanTbl.filter(idCol == handloanId)
                if let hl = try database.pluck(filteredTbl) {
                    return Handloan(id: hl[idCol], type: HandloanType(rawValue: hl[typeCol])!, name: hl[nameCol], datetime: TimeInterval(hl[datetimeCol]), amount: hl[amountCol], comments: hl[commentsCol], accountId: hl[accountIdCol])
                }
            } catch {
                throw error
            }
        } else {
            throw DBError.InvalidDatabaseConnection
        }
        return nil
    }
    fileprivate func deleteHandloan(withId handloanId: String) throws {
        if let database = database {
            do {
                let handloanTbl = Table("handloans")
                let idCol = Expression<String>("id")
                let filteredTbl = handloanTbl.filter(idCol == handloanId)
                try database.run(filteredTbl.delete())
            } catch {
                throw error
            }
        } else {
            throw DBError.InvalidDatabaseConnection
        }
    }
    fileprivate func fetchTransactions(forHandloanId handloanId: String) throws -> [Transaction] {
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
                
                let filteredTbl = transactionsTbl.filter(handloanIdCol == handloanId)
                for t in try database.prepare(filteredTbl) {
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
    fileprivate func deleteTransactions(withHandloanId handloanId: String) throws {
        if let database = database {
            do {
                let transactionsTbl = Table("transactions")
                let handloanIdCol = Expression<String>("handloanId")
                let filteredTbl = transactionsTbl.filter(handloanIdCol == handloanId)
                try database.run(filteredTbl.delete())
            } catch {
                throw error
            }
        } else {
            throw DBError.InvalidDatabaseConnection
        }
    }
}

extension Handloan {
    static func handloan(forId handloanId: String) throws -> Handloan? {
        do {
            return try DBManager.shared.fetchHandloan(forId: handloanId)
        } catch {
            throw error
        }
    }
    func transactions() throws -> [Transaction] {
        do {
            return try DBManager.shared.fetchTransactions(forHandloanId: self.id)
        } catch {
            throw error
        }
    }
    func save() throws {
        do {
            return try DBManager.shared.saveHandloan(self)
        } catch {
            throw error
        }
    }
    func delete() throws {
        do {
            return try DBManager.shared.deleteHandloan(withId: self.id)
        } catch {
            throw error
        }
    }
    func deleteTransactions() throws {
        do {
            return try DBManager.shared.deleteTransactions(withHandloanId: self.id)
        } catch {
            throw error
        }
    }
    
    func hasTransactions() -> Bool {
        do {
            let ts = try self.transactions()
            return ts.count > 0
        } catch {
            return false
        }
    }
}
