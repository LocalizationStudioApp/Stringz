//
//  LocalizableCellView.swift
//  Stringz
//
//  Created by Heysem Katibi on 12/24/16.
//  Copyright © 2016 Heysem Katibi. All rights reserved.
//

import Cocoa
import StringzCore

class LocalizableCellView: NSTableCellView {
    @IBOutlet var iconImage: NSImageView!
    @IBOutlet var labelName: NSTextField!
    @IBOutlet var labelCount: NSTextField!
    @IBOutlet var labelDescription: NSTextField!
    @IBOutlet var progressIndicator: NSProgressIndicator!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    var hasLongName = false

    var localizable: Localizable? {
        didSet {
            var nameColor = NSColor.labelColor
            var countHidden = true
            var descriptionHidden = false
            var progressHidden = true

            switch localizable?.status {
            case .ready,
                 .saving:
                countHidden = false
            case .loading:
                nameColor = .secondaryLabelColor
                progressHidden = false
            case .unloaded:
                nameColor = .tertiaryLabelColor
            case .unlocalized:
                nameColor = .tertiaryLabelColor
                descriptionHidden = true

            default: break
            }

            var toolTip = ""
            var iconName: String
            var name = ""
            var count = ""
            var description = ""

            if let parentName = localizable?.parentName, !parentName.isEmpty {
                toolTip += parentName + "/"
                if hasLongName {
                    name += toolTip
                }
            }
            if let namez = localizable?.name, !namez.isEmpty {
                if localizable?.localizableType == .config {
                    name += namez
                } else {
                    name += namez.components(separatedBy: ".").first ?? ""
                }
                toolTip += namez
            }
            self.toolTip = toolTip
            labelName.stringValue = name

            if localizable?.status == .ready || localizable?.status == .saving {
                let total = localizable?.totalCount ?? 0
                let translated = localizable?.translatedCount ?? 0

                var percentage: Double = 0
                if total == 0 {
                    percentage = 100
                } else {
                    percentage = Double(translated) / Double(total) * 100
                }

                count = "\(translated)/\(total)"
                description = "\(Int(percentage))% completed"
            } else if localizable?.status == .loading {
                description = "Loading..."
            } else if localizable?.status == .unloaded {
                description = "Unloaded"
            }

            switch localizable?.localizableType {
            case .storyboard:
                iconName = "file.storyboard"
            case .xib:
                iconName = "file.xib"
            case .strings:
                iconName = "file.strings"
            case .config:
                iconName = "file.config"
            default:
                iconName = "file.other"
            }

            labelName.textColor = nameColor
            labelCount.isHidden = countHidden
            labelDescription.isHidden = descriptionHidden
            if progressHidden {
                progressIndicator.isHidden = true
                progressIndicator.stopAnimation(progressIndicator)
            } else {
                progressIndicator.isHidden = false
                progressIndicator.startAnimation(progressIndicator)
            }
            self.toolTip = toolTip
            iconImage.image = NSImage(named: iconName)!
            labelName.stringValue = name
            labelCount.stringValue = count
            labelDescription.stringValue = description
        }
    }
}
