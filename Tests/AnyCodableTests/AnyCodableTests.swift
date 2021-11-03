import XCTest
@testable import AnyCodable

final class AnyCodableTests: XCTestCase {
    
    func testOne() throws {
        let store = TestStore(values: [
            "name": "jose",
            "age":  23,
            "dob": Date(),
            "list": [1, 2, 3]
        ])
        let p = try StoreDecoder.decode(Person.self, from: store)
        
        Swift.print (p)
        XCTAssertEqual(p.name, "jose")
    }

    func testNested() throws {
        let store = TestStore(values: [
            "name": "jose",
            "age":  23,
            "dob": Date(),
            "list": [1, 2, 3],
            "friend": [
                "name": "jane",
                "age":  23,
                "dob": Date(),
            ]
        ])
        let p = try StoreDecoder.decode(Person.self, from: store)
        
        Swift.print (p)
        XCTAssertEqual(p.name, "jose")
    }

    func testValue() throws {
        let v = Value.text("23")
//        let iv: Int = try v.cast()
        let dv: Double = try v.cast()
        let tv = try v.cast(to: String.self)
        
        print (dv, tv)
    }
}

class Person: Codable {
    var name: String
    var age: Int
    var dob: Date?
    var list: [Int]
    var friend: Person?
}

struct TestStore: ReadableStore {
    let values: [String: Any]
    
    enum _Error: Error {
        case notImplemented
        case unsupported(Any.Type)
        case missingValueFor(CodingKey)
    }
    
    // We support non-present keys as indicating a nil value
    func contains(_ key: PathKey, at: [PathKey]) -> Bool {
        true
    }
    
    func readNil(forKey key: PathKey, at: [PathKey]) throws -> Bool {
        values[key.stringValue] == nil
    }

    func read<T>(via: [PathKey], at key: PathKey, as: T.Type) throws -> T {
        guard values[key.stringValue] != nil else {
            throw _Error.missingValueFor(key) }
        let v = values[key.stringValue]
        if let v = v as? T { return v }
//        if v is Decodable {
//            let t = type(of: v) as? Decodable.Type
//            return StoreDecoder.decode(t, from: self)
//        }
        throw _Error.unsupported(T.self)
    }
    
    func read<T: Decodable>(via: [PathKey], at ndx: Int, as: T.Type) throws -> T {
        throw _Error.notImplemented
    }
}

