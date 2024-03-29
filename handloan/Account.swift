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
