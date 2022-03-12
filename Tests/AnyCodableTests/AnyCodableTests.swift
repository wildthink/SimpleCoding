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
            ] // as! [String:Decodable]
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
    
    // We support non-present keys as indicating a nil value
    func contains(_ key: PathKey, at: [PathKey]) -> Bool {
        true
    }
    
    func readNil(forKey key: PathKey, at path: [PathKey]) throws -> Bool {
        nil == (rawValue(path: path) as? [String:Any])?[key.stringValue]
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
    
    func rawValue(path: [PathKey]) -> Any? {
        var rv: Any? = values
        
        for p in path {
            if let map = rv as? [String:Any] {
                rv = map[p.stringValue]
            }
            else if let vec = rv as? [Any] {
                rv = vec[p.intValue ?? 0]
            }
        }
        return rv
    }
    
    func read<T>(via path: [PathKey], at key: PathKey, as rtype: T.Type)
    throws -> Any
    {
        var raw = (rawValue(path: path) as? [String:Any])?[key.stringValue]
        
        if raw == nil {
            raw = try? defaultValue(for: key, cast: T.self)
        }
        
        return raw as Any
/*
        // if the value `v` is already of the expected
        // type then simply return it
        if let v = raw as? T { return v }
        
        // Otherwise create a new `Decoder` that instantiates
        // a `T` from the supplied data `v` of Any
        guard let dt: Decodable.Type = rtype as? Decodable.Type
        else {
            throw _Error.unsupported(T.self, key)
        }
        return try dt.init(
            from: StoreDecoder(
                store: self,
                codingPath: path.appending(key),
                userInfo: [:]))

//        throw _Error.unsupported(T.self, key)

//        print(dt, type(of: dt))
        // (T.Type.self as? OptionalDecodable)
//        return undefined()
//        let nestedStore = try nestedStore(forKey: key, at: via)
//        return try dt.init(from: StoreDecoder(store: nestedStore))
 */
    }
    
    func read<T>(via path: [PathKey], at ndx: Int, as rtype: T.Type) throws -> Any {
        let raw = (rawValue(path: path) as? [Any])
        guard raw != nil
        else { throw _Error.missingValueAt(ndx) }
        return raw as Any
//        if let v = raw as? T { return v }
//
//        guard let dt: Decodable.Type = rtype as? Decodable.Type
//        else {
//            throw _Error.unsupported(T.self, path.first!)
//        }
//        return try dt.init(
//            from: StoreDecoder(
//                store: self,
//                codingPath: path.appending(AnyCodingKey(intValue: ndx)!),
//                userInfo: [:]))

        
//       throw _Error.notImplemented
    }
}
