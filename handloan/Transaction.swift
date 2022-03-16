//
//  Transaction.swift
//  handloan
//
//  Created by Mehul Bhavani on 26/02/22.
//

import Foundation

enum TransactionType: String {
    case send
    case receive
}

struct Transaction {
    let id: String
    var type: TransactionType
    var datetime: TimeInterval
    var amount: Double
    var comments: String
    var handloanId: String
    
    init(
        id: String = UUID().uuidString,
        type: TransactionType,
        datetime: TimeInterval,
        amount: Double,
        comments: String,
        handloanId: String) {
        self.id = id
        self.type = type
        self.datetime = datetime
        self.amount = amount
        self.comments = comments
        self.handloanId = handloanId
    }
    
    func dictionary() -> String {
        return [
            "id": id,
            "type": type.rawValue,
            "datetime": Date(timeIntervalSince1970: datetime).description,
            "amount": amount,
            "comments": comments,
            "handloanId": handloanId
        ].jsonify()
    }
}
