//
//  Value.swift
//  Stringz
//
//  Created by Heysem Katibi on 12/26/16.
//  Copyright © 2016 Heysem Katibi. All rights reserved.
//

import Foundation

/// Represents a value from a specific language with its key and comment.
///
/// This type is useful when saving files to the drive disk where we need the key, value, and comment values for a  particular language.
public struct ValueHolder {
    public let key: String
    public let value: String
    public let comment: String
    public let variableName: String?

    public let originalIndex: Int?
    public let baseIndex: Int?
}

/// Represents an individual string inside a localizable file,
/// This string should be in the same language as the file it comes from.
public class Value {
    public let uuid = UUID()

    /// The language of the localizable string.
    public let language: Language

    /// The value of the localizable string.
    public var value: String

    /// Contains the name of the variable that holds the string value
    /// This is used for .plist files where the string values are stored in the configuration of the Xcode project
    /// and then referenced from within the .plist file. Could be nil if the value is written directly without a variable.
    public var variableName: String?

    /// The order of the value in its original file
    public var originalIndex: Int?

    /// Extra information to attach to the value
    public var extras: [String: Any] = [:]

    public init(language: Language, value: String) {
        self.language = language
        self.value = value
    }
}

extension Value: Hashable {
    public static func == (lhs: Value, rhs: Value) -> Bool {
        return lhs.uuid == rhs.uuid
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}

extension Array where Element == Value {
    public func value(for language: Language) -> Value? {
        return first(where: { $0.language == language })
    }
}
