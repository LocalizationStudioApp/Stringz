//
//  WelcomeWindowController+Class.swift
//  Stringz
//
//  Created by JH on 2023/6/29.
//

import AppKit
import SnapKit
import SwiftUI
import CocoaPreviews

class TrackButton: NSButton {
    var shouldTrackMouseEnteredAndExited: Bool { true }

    override func updateTrackingAreas() {
        guard shouldTrackMouseEnteredAndExited else { return }
        trackingAreas.forEach { removeTrackingArea($0) }
        let newArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect], owner: self, userInfo: nil)
        addTrackingArea(newArea)
    }
}

class TrackView: NSView {
    var shouldTrackMouseEnteredAndExited: Bool { true }

    override func updateTrackingAreas() {
        guard shouldTrackMouseEnteredAndExited else { return }
        trackingAreas.forEach { removeTrackingArea($0) }
        let newArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect], owner: self, userInfo: nil)
        addTrackingArea(newArea)
    }
}

class WelcomeView: TrackView {
    var mouseEnteredHandler: ((NSEvent) -> Void)?
    var mouseExitedHandler: ((NSEvent) -> Void)?

    override func mouseEntered(with event: NSEvent) {
        mouseEnteredHandler?(event)
    }

    override func mouseExited(with event: NSEvent) {
        mouseExitedHandler?(event)
    }
}

class CloseButton: TrackButton {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
    }

    override func mouseEntered(with event: NSEvent) {}

    override func mouseExited(with event: NSEvent) {}
}

class RecentEmptyView: NSView {
    let titleLabel = NSTextField(labelWithString: "No Recent Projects")

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.do {
            $0.font = .systemFont(ofSize: 20)
            $0.alignment = .center
        }
    }
}


struct WelcomeWindowComponents_Previews: PreviewProvider {
    static var previews: some View {
        RecentEmptyView()
            .asSwiftUIPreviews()
            .frame(width: 300, height: 600, alignment: .center)
    }
}
