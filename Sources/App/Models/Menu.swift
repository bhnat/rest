//
//  Menu.swift
//  rest
//
//  Created by Brian Hnat on 12/26/16.
//
//

import Vapor
import Fluent
import Foundation

//[DEPRECATED] No 'exists' property is stored on 'MenuItem'. Add `var exists: Bool = false` to this model. The default implementation will be removed in a future update.
//Unsupported Node type, only array is supported.
//[DEPRECATED] No 'exists' property is stored on 'MenuItem'. Add `var exists: Bool = false` to this model. The default implementation will be removed in a future update.

final class MenuItem: Model {
    var id: Node?
    var name: String
    var price:Double
    var isSpecial:Bool
    var exists: Bool = false
    
    init(name: String, price:Double, isSpecial:Bool) {
        self.id = nil // UUID().uuidString.makeNode()
        self.name = name
        self.price = price
        self.isSpecial = isSpecial
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("_id")
        name = try node.extract("name")
        price = try node.extract("price")
        isSpecial = try node.extract("isSpecial")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "_id": id,
            "name": name,
            "price": price,
            "isSpecial": isSpecial
            ])
    }
}

//extension MenuItem {
//    /**
//     This will automatically fetch from database, using example here to load
//     automatically for example. Remove on real models.
//     */
//    public convenience init?(from string: String) throws {
//        self.init(content: string)
//    }
//}

extension MenuItem: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("menuItems") { items in
            items.id()
            items.string("name")
            items.double("price")
            items.bool("isSpecial")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("menuItems")
    }
}
