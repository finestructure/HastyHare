//
//  Message.swift
//  HastyHare
//
//  Created by Sven A. Schmidt on 02/11/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation


public enum Message: CustomStringConvertible {
    case Text(String)
    case Data(NSData)


    public init(_ string: String) { self = .Text(string) }


    public init(_ data: NSData) { self = .Data(data) }


    public var string: String? {
        switch self {
        case .Text(let s):
            return s
        case .Data:
            return nil
        }
    }


    public var data: NSData? {
        switch self {
        case .Text:
            return nil
        case .Data(let d):
            return d
        }
    }


    public var description: String {
        switch self {
        case .Text(let s):
            return ".Text (\(s))"
        case .Data:
            return ".Data (\(self.data!.length) bytes)"
        }
    }

}


extension Message: Equatable {

}


public func ==(lhs: Message, rhs: Message) -> Bool {

    switch (lhs, rhs) {
    case (.Text(let x), .Text(let y)):
        return x == y
    case (.Data(let x), .Data(let y)):
        return x == y
    default:
        return false
    }

}
