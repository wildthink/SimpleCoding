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

    // Missing Arrays should return an empty Array
    func testMissingArray() throws {
        let store = TestStore(values: [
            "name": "jose",
            "age":  23,
            "dob": Date(),
            //            "list": [1, 2, 3]
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
                "age":  21,
                "dob": Date(),
                "list": [1, 2]
            ]
        ])
        let p = try StoreDecoder.decode(Person.self, from: store)
        
        Swift.print (p)
        XCTAssertEqual(p.name, "jose")
    }

    func testValue() throws {
        let v = Value.text("23")
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
    var kids: [Person]
}

struct TestStore: ReadableStore {
    
    let values: [String: Any]
    
    enum _Error: Error {
        case notImplemented
        case unsupported(Any.Type, CodingKey)
        case missingValueFor(CodingKey)
        case noNestedStoreFor(CodingKey, [PathKey])
    }
    
    func nestedStore(forKey key: PathKey, at: [PathKey]) throws -> ReadableStore {
        guard let data = values[key.stringValue] as? [String:Any]
        else {
            throw _Error.noNestedStoreFor(key, at)
        }
        return Self.init(values: data)
    }
    
    // We support non-present keys as indicating a nil value
    func contains(_ key: PathKey, at: [PathKey]) -> Bool {
        true
    }
    
    func readNil(forKey key: PathKey, at: [PathKey]) throws -> Bool {
        values[key.stringValue] == nil
    }

    func defaultValue<D: Decodable>(for key: CodingKey, cast: D.Type = D.self) throws -> D {
        switch D.self {
            case let f as ArrayProtocol.Type:
                return f.empty() as! D
            case let f as ExpressibleByNilLiteral.Type:
                return f.init(nilLiteral: ()) as! D
            default:
                throw _Error.missingValueFor(key)
        }
    }
    
    func read<T: Decodable>(via: [PathKey], at key: PathKey, as rtype: T.Type)
    throws -> T
    {
        guard values[key.stringValue] != nil else {
            return try defaultValue(for: key)
        }
        let v = values[key.stringValue]
        // if the value `v` is already of the expected
        // type then simply return it
        if let v = v as? T { return v }
        
        // Otherwise create a new `Decoder` that instantiates
        // a `T` from the supplied data `v` of Any
        let nestedStore = try nestedStore(forKey: key, at: via)
        return try StoreDecoder.decode(T.self, from: nestedStore)
    }
    
    func read<T>(via: [PathKey], at ndx: Int, as: T.Type) throws -> T {
        throw _Error.notImplemented
    }

}


protocol ArrayProtocol {
    static func empty() -> Self
    static var elementType: Any.Type { get }
}

extension Array: ArrayProtocol {
    static var elementType: Any.Type { Self.Element.self }
    static func empty() -> Self { [] }
}
