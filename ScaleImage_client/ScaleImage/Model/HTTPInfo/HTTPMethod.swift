//
//  HTTPMethod.swift
//  ScaleImage
//
//  Created by Андрей Шамин on 8/7/22.
//

enum HTTPMethod: String {
    case get, post, patch, delete, put

    var stringValue: String {
        return self.rawValue.uppercased()
    }
}
