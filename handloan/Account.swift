//
//  Account.swift
//  handloan
//
//  Created by Mehul Bhavani on 26/02/22.
//

import Foundation

struct Account {
    let id: String
    var name: String
    var comments: String
    
    init(
        id: String = UUID().uuidString,
        name: String,
        comments: String) {
        self.id = id
        self.name = name
        self.comments = comments
    }
    
    func dictionary() -> String {
        return [
            "id": id,
            "name": name
        ].jsonify()
    }
}
extension Account {
    static func fetchAll() throws -> [Account] {
        do {
            return try DBManager.shared.fetchAccounts()
        } catch {
            throw error
        }
    }
    func handloans() throws -> [Handloan] {
        do {
            return try DBManager.shared.fetchHandloansFor(accountId: self.id)
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
}
