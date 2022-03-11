//
//  File.swift
//  
//
//  Created by Jason Jobe on 3/10/22.
//

import Foundation

//public protocol KeyedStoreDecoder: KeyedDecodingContainerProtocol {
//    var store: ReadableStore { get }
//    func read<T: Decodable>( _ key: Key) throws -> T
////    func read<T: Decodable>( _ key: Key, as: T.Type) throws -> T
//}

/***
 Both Readable and Writable Stores have an explicit "root", from
 which a path which can be "traversed" to either a Keyed or UnKeyed
 container of values.
 */
public protocol ReadableStore {
    typealias PathKey = CodingKey
    
    //    func read<T: Decodable>(via: [PathKey], at: PathKey, as: T.Type) throws -> T
    //    func read<T: Decodable>(via: [PathKey], at ndx: Int, as: T.Type) throws -> T
    
    func read<T>(via: [PathKey], at: PathKey, as: T.Type)
    throws -> Any
    
    func read<T>(via: [PathKey], at ndx: Int, as: T.Type)
    throws -> Any
    
    func count(at: [PathKey]) -> Int
    
    func contains(_ key: PathKey, at: [PathKey]) -> Bool
    func readNil(forKey key: PathKey, at: [PathKey]) throws -> Bool
    
    // jmj
    func nestedStore(forKey key: PathKey, at: [PathKey]) throws -> ReadableStore
}

public protocol WrtiableStore {
    typealias PathKey = CodingKey
    func write<T: Encodable>(value: T, via: [PathKey], at: PathKey) throws
    func write<T: Encodable>(value: T, via: [PathKey], at ndx: Int) throws
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
//public extension ReadableStore {
//    func read<T: Decodable>(via: [PathKey], at ndx: Int, inferringAs: T.Type = T.self) throws -> Any {
//        try self.read(via: via, at: ndx, as: T.self)
//    }
//    func read<T: Decodable>(via: [PathKey], at key: PathKey, inferringAs: T.Type = T.self) throws -> Any {
//        try self.read(via: via, at: key, as: T.self)
//    }
//}
