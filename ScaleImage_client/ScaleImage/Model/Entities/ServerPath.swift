//
//  ServerPath.swift
//  ScaleImage
//
//  Created by Андрей Шамин on 8/7/22.
//

import Foundation

enum ServerPath {
    case scaleImagePath
    case testGet

    var stringPath: String {
        switch self {
        case .scaleImagePath:
            return "/"
        case .testGet:
            return "/custom"
        }
    }
}
