//
//  PlistPreferenceViewController.swift
//  Stringz
//
//  Created by Heysem Katibi on 9.12.2020.
//

import Cocoa
import Preferences
import StringzCore

final class PlistPreferenceViewController: PreferenceViewController, PreferencePane {
    let preferencePaneIdentifier = Preferences.PaneIdentifier.plist
    let preferencePaneTitle = "Plist"
    let toolbarItemIcon = NSImage(named: "preferences.plist")!
    override var nibName: NSNib.Name? { "PlistPreference" }

    @IBOutlet var arrayController: NSArrayController!
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var segmentedControl: NSSegmentedControl!

    @objc dynamic var plistKeys: [PlistKey]!
    @objc dynamic var sortDescriptors = [
        NSSortDescriptor(key: "name", ascending: true) { ($0 as! String).localizedCaseInsensitiveCompare($1 as! String) },
        NSSortDescriptor(key: "friendlyName", ascending: true) { ($0 as! String).localizedCaseInsensitiveCompare($1 as! String) },
    ]

    private var shouldAcceptEditing = true

    override func viewDidLoad() {
        super.viewDidLoad()
        plistKeys = UserDefaults.plistKeys
    }

    private func uuidForRow(_ rowIndex: Int) -> String? {
        return ((tableView.rowView(atRow: rowIndex, makeIfNecessary: true)?.view(atColumn: 0) as? NSTableCellView)?.subviews[1] as? NSTextField)?.stringValue
    }

    @IBAction func segmentedControlClicked(_ sender: Any) {
        guard let segmentedControl = sender as? NSSegmentedControl else { return }
        switch segmentedControl.selectedSegment {
        case 0:
            let newUuid = UUID().uuidString
            plistKeys.append(PlistKey(uuid: newUuid, name: "", friendlyName: ""))

            DispatchQueue.main.async {
                for index in 0 ..< self.plistKeys.count {
                    if self.uuidForRow(index) == newUuid {
                        self.tableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
                        self.tableView.editColumn(0, row: index, with: nil, select: true)

                        break
                    }
                }
            }

        case 1:
            let uuidsToRemove = tableView.selectedRowIndexes.map { self.uuidForRow($0) }
            plistKeys = plistKeys.filter { !uuidsToRemove.contains($0.uuid) }
            segmentedControl.setEnabled(false, forSegment: 1)
            UserDefaults.plistKeys = plistKeys
        case 2:
            UserDefaults.plistKeys = UserDefaults.plistDefaultKeys
            plistKeys = UserDefaults.plistDefaultKeys
        default:
            break
        }
    }
}

extension PlistPreferenceViewController: NSTableViewDelegate, NSTextFieldDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        segmentedControl.setEnabled(tableView.selectedRow != -1, forSegment: 1)
    }

    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        // A stupid workarround because this method is being called twice with empty value in the second time
        guard shouldAcceptEditing else {
            shouldAcceptEditing = true
            return true
        }
        shouldAcceptEditing = false
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { self.shouldAcceptEditing = true }

        guard tableView.selectedRow != -1,
              let uuid = uuidForRow(tableView.selectedRow),
              let plistKey = plistKeys.first(where: { $0.uuid == uuid })
        else { return false }

        let identifier = control.identifier?.rawValue
        let newValue = fieldEditor.string

        if identifier == "name" {
            if plistKeys.contains(where: { $0.name == newValue }) { return false }
            plistKey.name = newValue
        } else if identifier == "friendlyName" {
            plistKey.friendlyName = newValue
        }

        UserDefaults.plistKeys = plistKeys
        return true
    }
}


