//
//  PreferenceViewController.swift
//  Stringz
//
//  Created by Heysem Katibi on 1.01.2021.
//

import Cocoa

class PreferenceViewController: NSViewController {
    override func viewWillAppear() {
        super.viewWillAppear()
        view.subviews.first?.alphaValue = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            self.view.subviews.first?.animator().alphaValue = 1
        }
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        view.subviews.first?.animator().alphaValue = 0
    }
}
