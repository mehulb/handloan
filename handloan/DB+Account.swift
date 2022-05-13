//
//  DB+Account.swift
//  handloan
//
//  Created by Mehul Bhavani on 02/03/22.
//

import Foundation
import SQLite

extension DBManager {
    fileprivate func saveAccount(_ a: Account) throws {
        Logger.debug("Add account: \(a.dictionary())")
        if let database = database {
            do {
                let accountsTbl = Table("accounts")
                
                let idCol = Expression<String>("id")
                let nameCol = Expression<String>("name")
                let commentsCol = Expression<String>("comments")
                
                try database.run(accountsTbl.insert(or: .replace, idCol <- a.id, nameCol <- a.name, commentsCol <- a.comments))
            } catch {
                throw error
            }
        } else {
            throw DBError.InvalidDatabaseConnection
        }
    }
    fileprivate func fetchAccounts() throws -> [Account] {
        var accounts = [Account]()
        if let database = database {
            do {
                let accountsTbl = Table("accounts")
                
                let idCol = Expression<String>("id")
                let nameCol = Expression<String>("name")
                let commentsCol = Expression<String>("comments")
                
                for acc in try database.prepare(accountsTbl) {
                    accounts.append(Account(id: acc[idCol], name: acc[nameCol], comments: acc[commentsCol]))
                }
                return accounts
            } catch {
                throw error
            }
        } else {
            throw DBError.InvalidDatabaseConnection
        }
    }
    fileprivate func fetchAccount(forId accountId: String) throws -> Account? {
        if let database = database {
            do {
                let accountsTbl = Table("accounts")
                
                let idCol = Expression<String>("id")
                let nameCol = Expression<String>("name")
                let commentsCol = Expression<String>("comments")
                
                let filteredTbl = accountsTbl.filter(idCol == accountId)
                if let accountRow = try database.pluck(filteredTbl) {
                    return Account(id: accountRow[idCol], name: accountRow[nameCol], comments: accountRow[commentsCol])
                }
            } catch {
                throw error
            }
        } else {
            throw DBError.InvalidDatabaseConnection
        }
        return nil
    }
    fileprivate func deleteAccount(withId accountId: String) throws {
        if let database = database {
            do {
                let accountsTbl = Table("accounts")
                let idCol = Expression<String>("id")
                let filteredTbl = accountsTbl.filter(idCol == accountId)
                try database.run(filteredTbl.delete())
            } catch {
                throw error
            }
        } else {
            throw DBError.InvalidDatabaseConnection
        }
    }
    fileprivate func fetchHandloans(forAccountId accountId: String) throws -> [Handloan] {
        var handloans = [Handloan]()
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
                
                let filteredTbl = handloanTbl.filter(accountIdCol == accountId)
                for hl in try database.prepare(filteredTbl) {
                    handloans.append(Handloan(id: hl[idCol], type: HandloanType(rawValue: hl[typeCol])!, name: hl[nameCol], datetime: TimeInterval(hl[datetimeCol]), amount: hl[amountCol], comments: hl[commentsCol], accountId: hl[accountIdCol]))
                }
                return handloans
            } catch {
                throw error
            }
        } else {
            throw DBError.InvalidDatabaseConnection
        }
    }
    fileprivate func deleteHandloans(withAccountId accountId: String) throws {
        if let database = database {
            do {
                let handloanTbl = Table("handloans")
                let accountIdCol = Expression<String>("accountId")
                let filteredTbl = handloanTbl.filter(accountIdCol == accountId)
                try database.run(filteredTbl.delete())
            } catch {
                throw error
            }
        } else {
            throw DBError.InvalidDatabaseConnection
        }
    }
}

extension Account {
    static func all() throws -> [Account] {
        do {
            return try DBManager.shared.fetchAccounts()
        } catch {
            throw error
        }
    }
    static func account(forId accountId: String) throws -> Account? {
        do {
            return try DBManager.shared.fetchAccount(forId: accountId)
        } catch {
            throw error
        }
    }
    func handloans() throws -> [Handloan] {
        do {
            return try DBManager.shared.fetchHandloans(forAccountId: self.id)
        } catch {
            throw error
        }
    }
    func save() throws {
        do {
            return try DBManager.shared.saveAccount(self)
        } catch {
            throw error
        }
    }
    func delete() throws {
        do {
            return try DBManager.shared.deleteAccount(withId: self.id)
        } catch {
            throw error
        }
    }
    func deleteHandloans() throws {
        do {
            return try DBManager.shared.deleteHandloans(withAccountId: self.id)
        } catch {
            throw error
        }
    }
    func balance() -> Double? {
        var amount = 0.0
        do {
            let hs = try self.handloans()
            for h in hs {
                if h.type == .borrow {
                    amount -= h.balance() ?? 0.0
                } else {
                    amount += h.balance() ?? 0.0
                }
            }
            return amount
        } catch {
            Logger.error(error.localizedDescription)
            return nil
        }
    }
}
