//
//  Handloan.swift
//  handloan
//
//  Created by Mehul Bhavani on 27/02/22.
//

import Foundation

enum HandloanType: String {
    case borrow
    case lend
}

struct Handloan {
    let id: String
    var type: HandloanType
    var name: String
    var datetime: TimeInterval
    var amount: Double
    var comments: String
    var accountId: String
    
    init(
        id: String = UUID().uuidString,
        type: HandloanType,
        name: String,
        datetime: TimeInterval,
        amount: Double,
        comments: String,
        accountId: String) {
            self.id = id
            self.type = type
            self.name = name
            self.datetime = datetime
            self.amount = amount
            self.comments = comments
            self.accountId = accountId
    }
    
    func dictionary() -> String {
        return [
            "id": id,
            "type": type.rawValue,
            "name": name,
            "datetime": Date(timeIntervalSince1970: datetime).description,
            "amount": amount,
            "comments": comments,
            "accountId": accountId
        ].jsonify()
    }
}
