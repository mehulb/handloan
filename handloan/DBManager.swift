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
    
    private(set) var database: Connection?
    
    private func setup() throws {
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
    
    func fetchDatabasePath() -> String? {
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

extension DBManager {
    func loadDummyData() {
        do {
            let simon = Account(name: "Simon", comments: "simon says!")
            _ = try simon.save()
            let s_hl_1 = Handloan(type: .borrow, name: "", datetime: "2021-01-18".toDate()!.timeIntervalSince1970, amount: 18000, comments: "Blah Blah", accountId: simon.id)
            _ = try s_hl_1.save()
            _ = try Transaction(type: .send, datetime: "2021-01-28".toDate()!.timeIntervalSince1970, amount: 10000, comments: "thank you", handloanId: s_hl_1.id).save()
            _ = try Transaction(type: .send, datetime: "2021-01-30".toDate()!.timeIntervalSince1970, amount: 8000, comments: "thank you again", handloanId: s_hl_1.id).save()
            
            let s_hl_2 = Handloan(type: .borrow, name: "", datetime: "2021-06-18".toDate()!.timeIntervalSince1970, amount: 35000, comments: "Blah Blah", accountId: simon.id)
            _ = try s_hl_2.save()
            _ = try Transaction(type: .send, datetime: "2021-07-11".toDate()!.timeIntervalSince1970, amount: 20000, comments: "thank you", handloanId: s_hl_2.id).save()
            _ = try Transaction(type: .send, datetime: "2021-08-15".toDate()!.timeIntervalSince1970, amount: 10000, comments: "thank you again", handloanId: s_hl_2.id).save()
            _ = try Transaction(type: .send, datetime: "2021-10-01".toDate()!.timeIntervalSince1970, amount: 3000, comments: "thank you a lot", handloanId: s_hl_2.id).save()
            
            let adam = Account(name: "Adam", comments: "and eve")
            _ = try adam.save()
            let a_hl_1 = Handloan(type: .lend, name: "", datetime: "2021-11-01".toDate()!.timeIntervalSince1970, amount: 100000, comments: "Lorem Ipsum", accountId: adam.id)
            _ = try a_hl_1.save()
            _ = try Transaction(type: .receive, datetime: "2021-12-12".toDate()!.timeIntervalSince1970, amount: 20000, comments: "1st installment", handloanId: a_hl_1.id).save()
            _ = try Transaction(type: .receive, datetime: "2022-01-05".toDate()!.timeIntervalSince1970, amount: 20000, comments: "2st installment", handloanId: a_hl_1.id).save()
            _ = try Transaction(type: .receive, datetime: "2021-01-30".toDate()!.timeIntervalSince1970, amount: 30000, comments: "3st installment", handloanId: a_hl_1.id).save()
            
            let kane = Account(name: "Kane", comments: "citizen cane")
            _ = try kane.save()
        } catch {
            Logger.error(error.localizedDescription)
        }
    }
}
