@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class UserTests: XCTestCase {
  let usersName = "Alice"
  let usersUsername = "alicea"
  let usersURI = "/api/users/"
  var app: Application!
  var conn: PostgreSQLConnection!
  
  override func setUp() {
    try! Application.reset()
    app = try! Application.testable()
    conn = try! app.newConnection(to: .psql).wait()
  }
  
  override func tearDown() {
    conn.close()
  }
  
  func testUsersCanBeRetrievedFromAPI() throws {
    let user = try User.create(
      name: usersName,
      username: usersUsername,
      on: conn)
    _ = try User.create(on: conn)
    
    let users = try app.getResponse(
      to: usersURI,
      decodeTo: [User].self)
    
    XCTAssertEqual(users.count, 2)
    XCTAssertEqual(users[0].name, usersName)
    XCTAssertEqual(users[0].username, usersUsername)
    XCTAssertEqual(users[0].id, user.id)
  }
  
  func testUserCanBeSavedWithAPI() throws {
    // 1
    let user = User(name: usersName, username: usersUsername)
    // 2
    let receivedUser = try app.getResponse(
      to: usersURI,
      method: .POST,
      headers: ["Content-Type": "application/json"],
      data: user,
      decodeTo: User.self)
    
    // 3
    XCTAssertEqual(receivedUser.name, usersName)
    XCTAssertEqual(receivedUser.username, usersUsername)
    XCTAssertNotNil(receivedUser.id)
    
    // 4
    let users = try app.getResponse(
      to: usersURI,
      decodeTo: [User].self)
    
    // 5
    XCTAssertEqual(users.count, 1)
    XCTAssertEqual(users[0].name, usersName)
    XCTAssertEqual(users[0].username, usersUsername)
    XCTAssertEqual(users[0].id, receivedUser.id)
  }
  
  func testGettingASingleUserFromTheAPI() throws {
    // 1
    let user = try User.create(
      name: usersName,
      username: usersUsername,
      on: conn)
    // 2
    let receivedUser = try app.getResponse(
      to: "\(usersURI)\(user.id!)",
      decodeTo: User.self)
    
    // 3
    XCTAssertEqual(receivedUser.name, usersName)
    XCTAssertEqual(receivedUser.username, usersUsername)
    XCTAssertEqual(receivedUser.id, user.id)
  }

  func testGettingAUsersAcronymsFromTheAPI() throws {
    // 1
    let user = try User.create(on: conn)
    // 2
    let acronymShort = "OMG"
    let acronymLong = "Oh My God"
    // 3
    let acronym1 = try Acronym.create(
      short: acronymShort,
      long: acronymLong,
      user: user,
      on: conn)
    _ = try Acronym.create(
      short: "LOL",
      long: "Laugh Out Loud",
      user: user,
      on: conn)

    // 4
    let acronyms = try app.getResponse(
      to: "\(usersURI)\(user.id!)/acronyms",
      decodeTo: [Acronym].self)

    // 5
    XCTAssertEqual(acronyms.count, 2)
    XCTAssertEqual(acronyms[0].id, acronym1.id)
    XCTAssertEqual(acronyms[0].short, acronymShort)
    XCTAssertEqual(acronyms[0].long, acronymLong)
  }

  static let allTests = [
    ("testUsersCanBeRetrievedFromAPI",
    testUsersCanBeRetrievedFromAPI),
    ("testUserCanBeSavedWithAPI", testUserCanBeSavedWithAPI),
    ("testGettingASingleUserFromTheAPI",
    testGettingASingleUserFromTheAPI),
    ("testGettingAUsersAcronymsFromTheAPI",
    testGettingAUsersAcronymsFromTheAPI)
  ]
}
