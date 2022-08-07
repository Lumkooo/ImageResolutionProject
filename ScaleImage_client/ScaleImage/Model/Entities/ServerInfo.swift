//
//  ServerInfo.swift
//  ScaleImage
//
//  Created by Андрей Шамин on 8/7/22.
//

import Foundation

enum ServerInfo {
    static private let sharedScheme = "http://"
    static private let hostName = "127.0.0.1"
    static private let serverPort = ":8080"

    static var mainDomain: String {
        return sharedScheme+hostName+serverPort
    }
}
