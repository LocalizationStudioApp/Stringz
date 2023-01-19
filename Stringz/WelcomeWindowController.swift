//
//  WelcomeWindowController.swift
//  Stringz
//
//  Created by JH on 2023/1/1.
//

import Cocoa
import DSFAppKitBuilder
import SwiftUI
import CocoaPreviews
import Defaults
import Combine
import SnapKit
import Collections
import MenuBuilder

class RecentProjectTableViewCell: NSTableCellView {
    @IBOutlet var iconImageView: NSImageView!
    @IBOutlet var nameField: NSTextField!
    @IBOutlet var pathField: NSTextField!
}

class WelcomeWindowController: NSWindowController {
    typealias Handler = (String?) -> Void

    @discardableResult
    static func createWelcomeWindow(openProjectHandler: @escaping Handler) -> WelcomeWindowController {
        let welcomeWindowController: WelcomeWindowController

        if let existWindowController = NSApplication.shared.windows.first(where: {
            $0.windowController is WelcomeWindowController
        })?.windowController as? WelcomeWindowController {
            welcomeWindowController = existWindowController
        } else {
            welcomeWindowController = WelcomeWindowController()
        }

        welcomeWindowController.openProjectHandler = openProjectHandler
        welcomeWindowController.window?.makeKeyAndOrderFront(nil)
        return welcomeWindowController
    }

    @IBOutlet private var welcomeView: WelcomeView!

    @IBOutlet private var closeWindowButton: NSButton!

    @IBOutlet private var showWindowButton: NSButton!

    @IBOutlet private var versionField: NSTextField!

    @IBOutlet private var openProjectActionView: NSView!

    @IBOutlet private var recentProjectTableView: NSTableView!

    @IBOutlet private var recentProjectView: NSView!

    private let recentProjectEmptyView = DSFAppKitBuilderView {
        ZStack {
            ZLayer(layoutType: .center) {
                Label("No Recent Projects")
                    .font(.systemFont(ofSize: 20))
                    .alignment(.center)
            }
        }
        .width(300)
    }

    @Default(.recentProjectPaths) var recentProjectPaths

    var cancellable: Set<AnyCancellable> = []

    var openProjectHandler: Handler?

    private var appVersion: String {
        Bundle.versionString ?? ""
    }

    private var appBuild: String {
        Bundle.buildString ?? ""
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        showWindowButton.alphaValue = 0
        closeWindowButton.alphaValue = 0
        window?.do {
            $0.center()
            $0.isMovableByWindowBackground = true
        }

        welcomeView.do {
            $0.wantsLayer = true
            $0.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
            $0.mouseEnteredHandler = { _ in
                self.showWindowButton.animator().alphaValue = 1
                self.closeWindowButton.animator().alphaValue = 1
            }
            $0.mouseExitedHandler = { _ in
                self.showWindowButton.animator().alphaValue = 0
                self.closeWindowButton.animator().alphaValue = 0
            }
        }

        versionField.do {
            $0.stringValue = "Version \(appVersion) (\(appBuild))"
        }

        openProjectActionView.do {
            $0.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(openNewProject(_:))))
        }

        _recentProjectPaths.publisher
            .sink { [weak self] paths in
                self?.recentProjectTableView.isHidden = paths.newValue.isEmpty
                self?.recentProjectEmptyView.isHidden = !paths.newValue.isEmpty
                self?.recentProjectTableView.reloadData()
            }
            .store(in: &cancellable)

        recentProjectView.do {
            $0.addSubview(recentProjectEmptyView)
        }

        recentProjectEmptyView.do {
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        recentProjectTableView.do {
            $0.menu = NSMenu {
                MenuItem("Show in Finder")
                    .onSelect { [weak self] in
                        guard let self = self, self.recentProjectTableView.clickedRow >= 0 else { return }
                        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: self.recentProjectPaths[self.recentProjectTableView.clickedRow])])
                    }
            }
        }
    }
    

    @objc func openNewProject(_ sender: NSClickGestureRecognizer) {
        openProjectHandler?(nil)
        close()
    }

    @IBAction func openRecentProject(_ sender: NSTableView) {
        openProjectHandler?(recentProjectPaths[sender.clickedRow])
        close()
    }

    @IBAction func closeWindowAction(_ sender: NSButton) { close() }

    @IBAction func changeShowWelcomeWhenLaunch(_ sender: NSButton) {}

    override var windowNibName: NSNib.Name? { .init(describing: Self.self) }
}

extension WelcomeWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        showWindowButton.alphaValue = 0
        closeWindowButton.alphaValue = 0
    }

    func windowDidBecomeKey(_ notification: Notification) {
        recentProjectTableView.reloadData()
        print(recentProjectPaths)
    }
}

extension WelcomeWindowController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        recentProjectPaths.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: .recentProjectTableViewCell, owner: self) as? RecentProjectTableViewCell else { return nil }
        let projectPath = recentProjectPaths[row]
        let properties = try? URL(fileURLWithPath: projectPath).resourceValues(forKeys: [.localizedNameKey, .effectiveIconKey])
        cell.iconImageView.image = properties?.effectiveIcon as? NSImage
        cell.nameField.stringValue = properties?.localizedName ?? ""
        cell.pathField.stringValue = projectPath
        return cell
    }
}

extension Bundle {
    /// Returns the main bundle's version string if available (e.g. 1.0.0)
    static var versionString: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    /// Returns the main bundle's build string if available (e.g. 123)
    static var buildString: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
}

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
