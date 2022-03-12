//
//  File.swift
//  
//
//  Created by Jason Jobe on 3/6/22.
//

import Foundation

public func undefined<T>(hint: String = "",
                         fn: String = #function,
                         file: StaticString = #file,
                         line: UInt = #line)
-> T {
    let message = hint == "" ? "" : ": \(hint)"
    fatalError("undefined \(T.self)\(message) fn:\(fn)",
               file:file, line:line)
}

struct UnkeyedContainer: UnkeyedDecodingContainer {

    let decoder: StoreDecoder
    var codingPath: [CodingKey] = []
    private(set) var currentIndex = 0

//    let store: KeyedStoreDecoder
//    let values: [SingleValueDecodingContainer]
    var count: Int? { decoder.store.count(at: codingPath) }
    var isAtEnd: Bool { return currentIndex == count }

//    init(values: [SingleValueDecodingContainer]) {
//        self.values = values
//    }
    
    mutating func decodeNil() throws -> Bool {
        return true
    }
    mutating func decode<T: Decodable>(_ type: T.Type) throws -> T {
        defer { currentIndex += 1 }
        let raw = try decoder.store.read(
            via: codingPath, at: currentIndex, as: T.self)
        // FIXME: Constrain the Store
        
        let decoder = StoreDecoder(
            store: self.decoder.store,
            codingPath: codingPath.appending(index: currentIndex),
            userInfo: [:])
        
            if let W = (T.Type.self as? OptionalDecodable)?.wrappedType() {
                return try W.init(from: self as! Decoder) as! T
            }
            return try T(from: decoder)
    }
    
    mutating func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
        return undefined()
//        return .init(KeyedContainer<NestedKey>())
    }
    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        undefined()
//        return UnkeyedContainer(values: [])
    }
    mutating func superDecoder() throws -> Decoder {
        return undefined()
    }
}

struct SingleValueContainer: SingleValueDecodingContainer {
    var codingPath: [CodingKey] { [] }
    var value: Any
    
    init(value: Any) {
        self.value = value
    }
    
    func decodeInteger<N: FixedWidthInteger>() throws -> N {
        (value as? N) ?? undefined()
    }
    
    // MARK: -- SingleValueDecodingContainer
    func decode(_ type: Double.Type)
    throws -> Double { return Double.random(in: 0...500) }
    
    func decode(_ type: Float.Type)
    throws -> Float { return Float.random(in: 0...500) }

    func decodeNil() -> Bool { return Bool.random() }
    
    func decode(_ type: Bool.Type)
    throws -> Bool { return value is ExpressibleByNilLiteral }
    
    func decode(_ type: String.Type)
    throws -> String { return undefined() }

    func decode(_ type: Int.Type)    throws -> Int    { try decodeInteger() }
    func decode(_ type: Int8.Type)   throws -> Int8   { try decodeInteger() }
    func decode(_ type: Int16.Type)  throws -> Int16  { try decodeInteger() }
    func decode(_ type: Int32.Type)  throws -> Int32  { try decodeInteger() }
    func decode(_ type: Int64.Type)  throws -> Int64  { try decodeInteger() }
    func decode(_ type: UInt.Type)   throws -> UInt   { try decodeInteger() }
    func decode(_ type: UInt8.Type)  throws -> UInt8  { try decodeInteger() }
    func decode(_ type: UInt16.Type) throws -> UInt16 { try decodeInteger() }
    func decode(_ type: UInt32.Type) throws -> UInt32 { try decodeInteger() }
    func decode(_ type: UInt64.Type) throws -> UInt64 { try decodeInteger() }
    
    func decode<T: Decodable>(_ type: T.Type)
    throws -> T {
        return undefined()
    }
}
