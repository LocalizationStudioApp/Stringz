//
//  Search.swift
//  Stringz
//
//  Created by JH on 2024/8/1.
//

import Foundation

public enum SearchType: Int {
    case all
    case untranslated
    case translated
}

public enum SearchScope: Int {
    case all
    case current
}

public enum SearchField: Int {
    case key
    case comment
    case values
}

public enum SearchMode: Int {
    case contains
    case startsWith
    case endsWith
    case regularExpression
}
