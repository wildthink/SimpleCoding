import XCTest
import SnapshotTesting
@testable import AnyCodable

final class AnyCodableTests: XCTestCase {
    
    let adate = Date(timeIntervalSince1970: 0)
    
    func testOne() throws {
        let store = TestStore(values: [
            "name": "jose",
            "age":  23,
            "dob": adate,
            "list": [1, 2, 3]
        ])
        let p = try StoreDecoder.decode(Person.self, from: store)
        
//        Swift.print (p)
        assertSnapshot(matching: p, as: .dump)
    }

    // Missing Arrays should return an empty Array
    func testMissingArray() throws {
        let empty: [Person] = .init()
        
        let store = TestStore(values: [
            "name": "jose",
            "age":  23,
            "dob": adate,
            "kids": empty
            //            "list": [1, 2, 3]
        ])
        let p = try StoreDecoder.decode(Person.self, from: store)
        
        Swift.print (p)
        assertSnapshot(matching: p, as: .dump)
    }

    func testNested() throws {
        let store = TestStore(values: [
            "name": "jose",
            "age":  23,
            "dob": adate,
            "list": [1, 2, 3],
            "friend": [
                "name": "jane",
                "age":  21,
                "dob": adate,
                "list": [1, 2]
            ] as! [String:Decodable]
        ])
        let p = try StoreDecoder.decode(Person.self, from: store)
        
        Swift.print (p)
        assertSnapshot(matching: p, as: .dump)
    }

    func testNestedArray() throws {
        let store = TestStore(values: [
            "name": "jose",
            "age":  23,
            "dob": adate,
            "list": [1, 2, 3],
            "kids": [[
                "name": "elroy",
                "age":  12,
                "dob": adate
            ]]
        ])
        let p = try StoreDecoder.decode(Person.self, from: store)
        
        Swift.print (p)
        assertSnapshot(matching: p, as: .dump)
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

struct ArrayStore: ReadableStore {
    
    let values: [Any]

    func count(at: [PathKey]) -> Int {
        values.count
    }

    func read<T>(via: [PathKey], at key: PathKey, as rtype: T.Type)
    throws -> Any
    {
        throw TestStore._Error.notImplemented
    }
    
    func read<T>(via: [PathKey], at ndx: Int, as: T.Type)
    throws -> Any {
        values[ndx]
    }

    // Readable Store auto-stubs
    func contains(_ key: PathKey, at: [PathKey])
    -> Bool {
        false
    }
    
    func readNil(forKey key: PathKey, at: [PathKey])
    throws -> Bool {
        false
    }
    
    func nestedStore(forKey key: PathKey, at: [PathKey])
    throws -> ReadableStore {
        throw TestStore._Error.notImplemented
    }
    
}


struct TestStore: ReadableStore {
    
    let values: [String: Any]
    
    enum _Error: Error {
        case notImplemented
        case unsupported(Any.Type, CodingKey)
        case missingValueFor(CodingKey)
        case missingValueAt(Int)
        case noNestedStoreFor(CodingKey, [PathKey])
    }
    
    func count(at: [PathKey]) -> Int {
        1
    }

    func nestedStore(forKey key: PathKey, at: [PathKey]) throws -> ReadableStore {
        if let data = values[key.stringValue] as? [String:Decodable] {
            return Self.init(values: data)
        }
        
        if let data = values[key.stringValue] as? [Any] {
            return ArrayStore(values: data)
        }
        else {
            return ArrayStore(values: .empty())
        }
    }

//    func nestedStore(forKey key: PathKey, at: [PathKey]) throws -> ReadableStore {
//        guard let data = values[key.stringValue] as? [String:Any]
//        else {
//            throw _Error.noNestedStoreFor(key, at)
//        }
//        return Self.init(values: data)
//    }
    
    // We support non-present keys as indicating a nil value
    func contains(_ key: PathKey, at: [PathKey]) -> Bool {
        true
    }
    
    func readNil(forKey key: PathKey, at: [PathKey]) throws -> Bool {
        values[key.stringValue] == nil
    }

    func defaultValue<D>(for key: CodingKey, cast: D.Type = D.self) throws -> D {
        switch D.self {
            case let f as ArrayProtocol.Type:
                return f.empty() as! D
            case let f as ExpressibleByNilLiteral.Type:
                return f.init(nilLiteral: ()) as! D
            default:
                throw _Error.missingValueFor(key)
        }
    }
    
    func read<T>(via: [PathKey], at key: PathKey, as rtype: T.Type)
    throws -> Any
    {
        guard values[key.stringValue] != nil else {
            return try defaultValue(for: key, cast: T.self)
        }
        let v = values[key.stringValue]
        // if the value `v` is already of the expected
        // type then simply return it
        if let v = v as? T { return v }
        
        // Otherwise create a new `Decoder` that instantiates
        // a `T` from the supplied data `v` of Any
        guard let dt: Decodable.Type = rtype as? Decodable.Type
        else {
            throw _Error.unsupported(T.self, key)
        }
//        print(dt, type(of: dt))
        // (T.Type.self as? OptionalDecodable)
//        return undefined()
        let nestedStore = try nestedStore(forKey: key, at: via)
        return try dt.init(from: StoreDecoder(store: nestedStore))
    }
    
    func read<T>(via: [PathKey], at ndx: Int, as: T.Type) throws -> Any {
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
