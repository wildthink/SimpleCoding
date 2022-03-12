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
            ],
             [
                "name": "judy",
                "age":  16,
                "dob": adate
             ]]
        ])
        let p = try StoreDecoder.decode(Person.self, from: store)
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

struct TestStore: ReadableStore {
    
    let values: [String: Any]
    
    enum _Error: Error {
        case notImplemented
        case unsupported(Any.Type, CodingKey)
        case missingValueFor(CodingKey)
        case missingValueAt(Int)
    }
    
    func count(at path: [PathKey]) -> Int {
        guard let rv = rawValue(path: path) else { return 0 }
        return (rv as? [Any])?.count ?? 1
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
        let raw = (rawValue(path: path) as? [String:Any])?[key.stringValue]
        return (try? raw ?? defaultValue(for: key, cast: T.self)) as Any
    }
    
    func read<T>(via path: [PathKey], at ndx: Int, as rtype: T.Type) throws -> Any {
        let raw = (rawValue(path: path) as? [Any])
        guard raw != nil
        else { throw _Error.missingValueAt(ndx) }
        return raw as Any
    }
}
