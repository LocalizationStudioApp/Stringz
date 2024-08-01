//
//  StoryboardPreferenceViewController.swift
//  Stringz
//
//  Created by Heysem Katibi on 22.12.2020.
//

import Cocoa
import Preferences

final class StoryboardPreferenceViewController: PreferenceViewController, PreferencePane {
    let preferencePaneIdentifier = Preferences.PaneIdentifier.xib
    let preferencePaneTitle = "Stoyboard / Xib"
    let toolbarItemIcon = NSImage(named: "preferences.storyboard")!
    override var nibName: NSNib.Name? { "StoryboardPreference" }

    @IBOutlet var pathControl: NSPathControl!
    @IBOutlet var changeLocationButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let path = UserDefaults.storyboardXcodePath, let url = URL(string: "file://\(path)") {
            pathControl.url = url
        }
    }

    @IBAction func changeLocationClicked(_ sender: Any) {}
}
