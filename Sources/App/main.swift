import Vapor
import VaporMongo
import HTTP
import Fluent

extension Query {
    
    public func optionalFilter(
        _ field: String,
        _ value: NodeRepresentable?) throws -> Query<Query.T> {
        
        guard let value = value else {
            return try makeQuery()
        }
        return try makeQuery().filter(field, value)
    }
}

let drop = Droplet(preparations: [MenuItem.self])

try drop.addProvider(VaporMongo.Provider.self)

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.get("test") { request in
    let menuItems = try MenuItem
        .query()
        .optionalFilter("name", request.data["name"]?.string)
        .optionalFilter("price", request.data["price"]?.double)
        .optionalFilter("isSpecial", request.data["isSpecial"]?.bool)
        .all()
    return try JSON(node: menuItems)
}

drop.get("test", ":id") { request in
    let id = try request.parameters.extract("id") as String
    //if let menuItem = try MenuItem.query().filter("_id", id).first() {
    if let menuItem = try MenuItem.find(id) {
        return menuItem
    } else {
        return Response(status: .notFound)
    }
}

drop.post("test") { request in
    var menuItem = try MenuItem(node: request.json)
    try menuItem.save()
    return menuItem
}

drop.delete("test", ":id") { request in
    let id = try request.parameters.extract("id") as String
    if let menuItem = try MenuItem.find(id) {
        try menuItem.delete()
        return Response(status: .ok)
    } else {
        return Response(status: .notFound)
    }
}

drop.put("test", ":id") { request in
    let id = try request.parameters.extract("id") as String
    var menuItem = try MenuItem(node: request.json)
    
    guard let fetch = try MenuItem.find(id) else {
        return Response(status: .notFound)
    }
    
    menuItem.id = fetch.id
    menuItem.exists = true
    try menuItem.save()
    return try JSON(node: menuItem)
}

// TODO: Implement patch
//drop.patch() { request in
//    return Response(status: .ok)
//}

drop.resource("posts", PostController())

drop.run()
