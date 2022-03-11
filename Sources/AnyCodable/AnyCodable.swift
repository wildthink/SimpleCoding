import Foundation
import CoreLocation


public struct StoreDecoder {
    
    var store: ReadableStore
    
    public private(set) var codingPath: [CodingKey] = []
    public private(set) var userInfo: [CodingUserInfoKey : Any] = [:]
    
    enum _Error: Error {
        case notImplemented(String = #function, String = #file, Int = #line)
        case unsupported(key: CodingKey, String = #function,
                         String = #file, Int = #line)
    }
}

extension StoreDecoder {
    
    static func decode<T: Decodable>(_ type: T.Type, from store: ReadableStore)
    throws -> T
    {
        let decoder = StoreDecoder(store: store)
        if let W = (T.Type.self as? OptionalDecodable)?.wrappedType() {
            return try W.init(from: self as! Decoder) as! T
        }
        return try T(from: decoder)
    }
    
}


extension StoreDecoder: Decoder {
    
    public func container<Key>(keyedBy type: Key.Type)
    -> KeyedDecodingContainer<Key> where Key : CodingKey {
        
        KeyedDecodingContainer(StoreDecoder.KeyedContainer<Key>(
            decoder: self,
            codingPath: [], userInfo: self.userInfo, allKeys: []))
    }
    
    public func unkeyedContainer() throws
    -> UnkeyedDecodingContainer {
        UnkeyedContainer(decoder: self, codingPath: [])
    }
    
    public func singleValueContainer() throws
    -> SingleValueDecodingContainer {
        throw StoreDecoder._Error.notImplemented()
    }
    //    }
}

// MARK: - KeyedContainer
extension StoreDecoder {
    struct KeyedContainer<Key>: KeyedDecodingContainerProtocol
    where Key: CodingKey {
        
        var decoder: StoreDecoder
        var codingPath: [CodingKey]
        public var userInfo: [CodingUserInfoKey : Any] = [:]
        var allKeys: [Key]
        
        var store: ReadableStore { decoder.store }
        
        func read<T: Decodable>( _ key: Key) throws -> T {
            guard let rval =
                    try store.read(via: codingPath, at: key, as: T.self) as? T
            else { throw _Error.unsupported(key: key) }
            return rval
        }
        
    }
}

// MARK: - KeyedDecodingContainerProtocol
extension StoreDecoder.KeyedContainer {
    
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
        undefined()
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        undefined()
        // TODO: Investigate if this is ALWAYS correct
    }
    
    func superDecoder() throws -> Decoder {
        throw StoreDecoder._Error.notImplemented()
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        throw StoreDecoder._Error.notImplemented()
    }
}


// MARK: - UnKeyedStoreDecoder
/*
 extension StoreDecoder {
 //    struct _UnkeyedDecoder<Key>: UnkeyedStoreDecoder
 //    where Key: CodingKey {
 //    }
 
 struct _UnkeyedDecoder : UnkeyedDecodingContainer {
 mutating func decodeNil() throws -> Bool {
 <#code#>
 }
 
 mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
 <#code#>
 }
 
 mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
 <#code#>
 }
 
 mutating func superDecoder() throws -> Decoder {
 <#code#>
 }
 
 // MARK: Properties
 /// A reference to the decoder we're reading from.
 //        private let decoder: _DictionaryDecoder
 
 /// A reference to the container we're reading from.
 private let container: [Any]
 
 /// The path of coding keys taken to get to this point in decoding.
 private(set) public var codingPath: [CodingKey]
 
 /// The index of the element we're about to decode.
 private(set) public var currentIndex: Int
 
 // MARK: - Initialization
 /// Initializes `self` by referencing the given decoder and container.
 fileprivate init(wrapping container: [Any]) {
 //            self.decoder = decoder
 self.container = container
 self.codingPath = decoder.codingPath
 self.currentIndex = 0
 }
 
 // MARK: - UnkeyedDecodingContainer Methods
 public var count: Int? {
 return self.container.count
 }
 
 public var isAtEnd: Bool {
 return self.currentIndex >= self.count!
 }
 }
 }
 */
