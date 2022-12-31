//
//  AddStringViewController.swift
//  Stringz
//
//  Created by Heysem Katibi on 2.01.2021.
//

import Cocoa

class AddStringViewController: NSViewController {
    @IBOutlet var textFieldKey: NSTextField!

    @objc dynamic var keyValue: String = ""
    @objc dynamic var errorValue: String = ""

    var addStringHandler: ((_ key: String) -> Void)?
    var validationHandler: ((_ key: String) -> Bool)?

    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldKey.stringValue = keyValue
    }

    @IBAction func addStringClicked(_ sender: Any) {
        guard let addStringHandler = addStringHandler, let validationHandler = validationHandler else { return }

        if validationHandler(keyValue) {
            errorValue = ""
            addStringHandler(keyValue)
            dismiss(self)
        } else {
            errorValue = "Key already exists in this file."
        }
    }
}

extension AddStringViewController {
    static func instantiateFromStoryboard() -> AddStringViewController {
        let storyboard = NSStoryboard(name: .main, bundle: nil)
        return storyboard.instantiateController(withIdentifier: .addStringViewController) as! AddStringViewController
    }
}

extension AddStringViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        keyValue = textFieldKey.stringValue
    }
}
