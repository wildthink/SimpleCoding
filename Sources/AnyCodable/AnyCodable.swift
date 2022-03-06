import Foundation
import CoreLocation

public protocol KeyedStoreDecoder: KeyedDecodingContainerProtocol {
    var store: ReadableStore { get }
    func read<T: Decodable>( _ key: Key) throws -> T
//    func read<T: Decodable>( _ key: Key, as: T.Type) throws -> T
}

/***
 Both Readable and Writable Stores have an explicit "root", from
 which a path which can be "traversed" to either a Keyed or UnKeyed
 container of values.
 */
public protocol ReadableStore {
    typealias PathKey = CodingKey
    func read<T: Decodable>(via: [PathKey], at: PathKey, as: T.Type) throws -> T
    func read<T: Decodable>(via: [PathKey], at ndx: Int, as: T.Type) throws -> T
    func contains(_ key: PathKey, at: [PathKey]) -> Bool
    func readNil(forKey key: PathKey, at: [PathKey]) throws -> Bool
    
    // jmj
    func nestedStore(forKey key: PathKey, at: [PathKey]) throws -> ReadableStore
}

public protocol WrtiableStore {
    typealias PathKey = CodingKey
    func write<T>(value: T, via: [PathKey], at: PathKey) throws
    func write<T>(value: T, via: [PathKey], at ndx: Int) throws
}

public protocol OptionalDecodable: Decodable {
    static
    func wrappedType() -> Decodable.Type
    func wrappedType() -> Decodable.Type
}

extension Optional: OptionalDecodable where Wrapped: Decodable {
    static
    public func wrappedType() -> Decodable.Type { Wrapped.self }
    public func wrappedType() -> Decodable.Type { Wrapped.self }
}

/// This method exists to enable the compiler to perform type inference on
/// the generic parameter `T` of `ReadableStore.read(via:at:as:)`. Protocols can
/// not provide default arguments to methods, which is required for
/// inference to work with generic type parameters. It is not expected that
/// user code will invoke this method directly; rather it will be selected
/// by the compiler automatically, as in this example:
///
/// ```
/// let row = getAnSQLRowFromSomewhere()
/// // `T` is inferred to be `Int`
/// let id: Int = try store.decode(via: path. at: "int")
/// // Error: No context to infer the type from.
/// let name = try store.decode(via: path. at: "name")
/// ```
///
/// - Note: The presence of this method in a protocol extension allows it to
///         be available without requiring explicit support from individual
///         database drivers.
public extension ReadableStore {
    func read<T: Decodable>(via: [PathKey], at ndx: Int, inferringAs: T.Type = T.self) throws -> T {
        try self.read(via: via, at: ndx, as: T.self)
    }
    func read<T: Decodable>(via: [PathKey], at key: PathKey, inferringAs: T.Type = T.self) throws -> T {
        try self.read(via: via, at: key, as: T.self)
    }
}

public class StoreDecoder {
    enum _Error: Error {
        case notImplemented(String = #function, String = #file, Int = #line)
        case unsupported(key: CodingKey, String = #function, String = #file, Int = #line)
    }

    static func decode<T: Decodable>(_ type: T.Type, from store: ReadableStore)
    throws -> T
    {
        let decoder = _StoreDecoder(store: store)
        if let W = (T.Type.self as? OptionalDecodable)?.wrappedType() {
            return try W.init(from: decoder) as! T
        }
        return try T(from: decoder)
    }
    
}


extension StoreDecoder {
    
    struct _StoreDecoder: Decoder {
        var store: ReadableStore
        
        var codingPath: [CodingKey] = []
        var userInfo: [CodingUserInfoKey : Any] = [:]
        
        public func container<Key>(keyedBy type: Key.Type) -> KeyedDecodingContainer<Key> where Key : CodingKey {

            let container = _KeyedDecoder<Key>(store: self.store, codingPath: [], userInfo: self.userInfo, allKeys: [])
            return KeyedDecodingContainer(container)
        }

        public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
            throw StoreDecoder._Error.notImplemented()
        }
        
        public func singleValueContainer() throws -> SingleValueDecodingContainer {
            throw StoreDecoder._Error.notImplemented()
        }
    }
}

extension StoreDecoder {
    struct _KeyedDecoder<Key>: KeyedStoreDecoder
    where Key: CodingKey {
        
        var store: ReadableStore
        var codingPath: [CodingKey]
        public var userInfo: [CodingUserInfoKey : Any] = [:]
        var allKeys: [Key]
        
        func read<T: Decodable>( _ key: Key) throws -> T {
            try store.read(via: codingPath, at: key, as: T.self)
        }

     }
}

// MARK: - KeyedDecodingContainerProtocol
extension KeyedStoreDecoder {
    
    func contains(_ key: Key) -> Bool {
        store.contains(key, at: codingPath)
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        try store.readNil(forKey: key, at: codingPath)
    }
    
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        try read(key)
    }
    
    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        try read(key)
    }
    
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        try read(key)
    }
    
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        try read(key)
    }
    
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        try read(key)
    }
    
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        try read(key)
    }
    
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        try read(key)
    }
    
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        try read(key)
    }
    
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        try read(key)
    }
    
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        try read(key)
    }
    
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        try read(key)
    }
    
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        try read(key)
    }
    
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        try read(key)
    }
    
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        try read(key)
    }
    
    func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        try read(key)
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        // TODO: Investigate if this is ALWAYS correct
        let nestedStore = try store.nestedStore(forKey: key, at: self.codingPath)
        return StoreDecoder._StoreDecoder(store: nestedStore)
            .container(keyedBy: NestedKey.self)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        throw StoreDecoder._Error.notImplemented()
    }
    
    func superDecoder() throws -> Decoder {
        throw StoreDecoder._Error.notImplemented()
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        throw StoreDecoder._Error.notImplemented()
    }
}
