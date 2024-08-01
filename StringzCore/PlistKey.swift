//
//  PlistKey.swift
//  Stringz
//
//  Created by JH on 2024/8/1.
//

import Foundation

public class PlistKey: NSObject, NSSecureCoding {
    @objc public dynamic var uuid: String
    @objc public dynamic var name: String
    @objc public dynamic var friendlyName: String

    public static var supportsSecureCoding: Bool {
        return true
    }

    public init(uuid: String, name: String, friendlyName: String) {
        self.uuid = uuid
        self.name = name
        self.friendlyName = friendlyName
    }

    public required convenience init(coder: NSCoder) {
        let uuid = coder.decodeObject(forKey: "uuid") as! String
        let name = coder.decodeObject(forKey: "name") as! String
        let friendlyName = coder.decodeObject(forKey: "friendlyName") as! String

        self.init(uuid: uuid, name: name, friendlyName: friendlyName)
    }

    public func encode(with coder: NSCoder) {
        coder.encode(uuid, forKey: "uuid")
        coder.encode(name, forKey: "name")
        coder.encode(friendlyName, forKey: "friendlyName")
    }
}

extension Array where Element == PlistKey {
    public mutating func appendIfDoesntExist(_ newElement: String) {
        if !contains(where: { $0.name == newElement }) {
            append(PlistKey(uuid: UUID().uuidString, name: newElement, friendlyName: ""))
        }
    }
}
