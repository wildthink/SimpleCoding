//
//  File.swift
//  
//
//  Created by Jason Jobe on 10/29/21.
//

import Foundation

public enum Value {
    enum Kind { case integer, real, text, blob, null, unknown }
    enum _Error: Error { case cantConvert }
    
    /// An integer value.
    case integer(Int64)
    /// A floating-point value.
    case real(Double)
    /// A text value.
    case text(String)
    /// A blob (untyped bytes) value.
    case blob(Data)
    /// A null value.
    case null
    
    var kind: Kind {
        switch self {
            case .integer(_): return .integer
            case .real(_): return .real
            case .blob(_): return .blob
            case .text(_): return .text
            case .null: return .null
        }
    }
}

extension Value {
    
    func cast<T>(to type: T.Type = T.self) throws -> T {
        switch self {
            case .blob(let v) where T.self is Data.Type:
               return v as! T
            case .integer(let v) where T.self is Int.Type:
                return v as! T
            case .text(let v) where T.self is String.Type:
                return v as! T
            case .text(let v) where T.self is Double.Type:
                return Double(v) as! T
            default:
                throw _Error.cantConvert
        }
    }
    
    func castingValue() throws -> Data {
        switch self {
            case .blob(let v):
                return v
            case .text(let v):
                guard let data = v.data(using: .utf8, allowLossyConversion: true)
                else { throw _Error.cantConvert }
                return data
            default:
                throw _Error.cantConvert
        }
    }
    
    func castingValue() throws -> Bool {
        switch self {
            case .integer(let v):
                return v != 0
            default:
                throw _Error.cantConvert
        }
    }
    
    func castingValue() throws -> String {
        switch self {
            case .integer(let v):
                return String(v)
            case .real(let v):
                return String(v)
            case .text(let v):
                return v
            default:
                throw _Error.cantConvert
        }
    }
    
    func castingValue() throws -> Double {
        switch self {
            case .integer(let v):
                return Double(v)
            case .real(let v):
                return Double(v)
            case .text(let v):
                guard let d = Double(v) else {
                    throw _Error.cantConvert
                }
                return d
            default:
                throw _Error.cantConvert
        }
    }
    
    func castingValue() throws -> Float {
        switch self {
            case .integer(let v):
                return Float(v)
            case .real(let v):
                return Float(v)
            case .text(let v):
                guard let d = Float(v) else {
                    throw _Error.cantConvert
                }
                return d
            default:
                throw _Error.cantConvert
        }
    }
    
    func castingValue<F: FixedWidthInteger>() throws -> F {
        switch self {
            case .integer(let v):
                return F(v)
            case .real(let v):
                return F(v)
            default:
                throw _Error.cantConvert
        }
    }
    
}

extension Value: Equatable {
    public static func ==(lhs: Value, rhs: Value) -> Bool {
        switch(lhs, rhs) {
            case (.integer(let lv), .integer(let rv)):
                return lv == rv
            case (.real(let lv), .real(let rv)):
                return lv == rv
            case (.text(let lv), .text(let rv)):
                return lv == rv
            case (.blob(let lv), .blob(let rv)):
                return lv == rv
            case (.null, .null):
                return true
            default:
                return false
        }
    }
}
