import Vapor
import FluentPostgreSQL

final class Acronym: Codable {
  var id: Int?
  var short: String
  var long: String
  var userID: User.ID

  init(short: String, long: String, userID: User.ID) {
    self.short = short
    self.long = long
    self.userID = userID
  }
}

//extension Acronym: Model {
//  typealias Database = SQLiteDatabase
//  typealias ID = Int
//
//  public static var idkey: IDKey = \Acronym.id
//}

extension Acronym: PostgreSQLModel {}

extension Acronym: Migration {
  static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
    return Database.create(self, on: conn) { builder in
      try addProperties(to: builder)
      builder.reference(from: \.userID, to: \User.id)
    }
  }
}

extension Acronym: Content {}

extension Acronym: Parameter {}

extension Acronym {
  var user: Parent<Acronym, User> {
    return parent(\.userID)
  }
}


