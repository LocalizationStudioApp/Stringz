//
//  IgnoredValue.swift
//  Stringz
//
//  Created by JH on 2024/8/1.
//

import Foundation

public class IgnoredValue: NSObject, NSSecureCoding {
    @objc public dynamic var uuid: String
    @objc public dynamic var name: String

    public static var supportsSecureCoding: Bool {
        return true
    }

    public init(uuid: String, name: String) {
        self.uuid = uuid
        self.name = name
    }

    public required convenience init(coder: NSCoder) {
        let uuid = coder.decodeObject(forKey: "uuid") as! String
        let name = coder.decodeObject(forKey: "name") as! String

        self.init(uuid: uuid, name: name)
    }

    public func encode(with coder: NSCoder) {
        coder.encode(uuid, forKey: "uuid")
        coder.encode(name, forKey: "name")
    }
}
