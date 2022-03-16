//
//  DB+Transaction.swift
//  handloan
//
//  Created by Mehul Bhavani on 16/03/22.
//

import Foundation
import SQLite

extension DBManager {
    fileprivate func saveTransaction(_ t: Transaction) throws {
        Logger.debug("Add transaction: \(t.dictionary())")
        if let database = database {
            do {
                let transactionsTbl = Table("transactions")
                
                let idCol = Expression<String>("id")
                let typeCol = Expression<String>("type")
                let datetimeCol = Expression<Int64>("datetime")
                let amountCol = Expression<Double>("amount")
                let commentsCol = Expression<String?>("comments")
                let handloanIdCol = Expression<String>("handloanId")
                
                try database.run(transactionsTbl.insert(or: .replace, idCol <- t.id, typeCol <- t.type.rawValue, datetimeCol <- Int64(t.datetime), amountCol <- t.amount, commentsCol <- t.comments, handloanIdCol <- t.handloanId))
            } catch {
                throw error
            }
        } else {
            throw DBError.InvalidDatabaseConnection
        }
    }
    fileprivate func fetchTransaction(forId transactionId: String) throws -> Transaction? {
        if let database = database {
            do {
                let transactionsTbl = Table("transactions")
                
                let idCol = Expression<String>("id")
                let typeCol = Expression<String>("type")
                let datetimeCol = Expression<Int64>("datetime")
                let amountCol = Expression<Double>("amount")
                let commentsCol = Expression<String>("comments")
                let handloanIdCol = Expression<String>("handloanId")
                
                let filteredTbl = transactionsTbl.filter(idCol == transactionId)
                if let t = try database.pluck(filteredTbl) {
                    return Transaction(id: t[idCol], type: TransactionType(rawValue: t[typeCol])!, datetime: TimeInterval(t[datetimeCol]), amount: t[amountCol], comments: t[commentsCol], handloanId: t[handloanIdCol])
                }
            } catch {
                throw error
            }
        } else {
            throw DBError.InvalidDatabaseConnection
        }
        return nil
    }
    fileprivate func deleteTransaction(withId transactionId: String) throws {
        if let database = database {
            do {
                let transactionsTbl = Table("transactions")
                let idCol = Expression<String>("id")
                let filteredTbl = transactionsTbl.filter(idCol == transactionId)
                try database.run(filteredTbl.delete())
            } catch {
                throw error
            }
        } else {
            throw DBError.InvalidDatabaseConnection
        }
    }
}

extension Transaction {
    static func transaction(forId transactionId: String) throws -> Transaction? {
        do {
            return try DBManager.shared.fetchTransaction(forId: transactionId)
        } catch {
            throw error
        }
    }
    func save() throws {
        do {
            return try DBManager.shared.saveTransaction(self)
        } catch {
            throw error
        }
    }
    func delete() throws {
        do {
            return try DBManager.shared.deleteTransaction(withId: self.id)
        } catch {
            throw error
        }
    }
    
}
