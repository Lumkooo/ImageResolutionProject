//
//  AppError.swift
//  ScaleImage
//
//  Created by Андрей Шамин on 8/7/22.
//

import Foundation

enum AppError {
    case server(type: Enums.NetworkErrors)

    class Enums { }
}

extension AppError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .server(let type): return type.localizedDescription
        }
    }
}

extension AppError.Enums {
    enum NetworkErrors {
        case cantGetURLRequest
        case cantGetData
        case cantDecodeResult
        case someBackendError(errorCode: Int?)
        case custom(errorCode: Int?, errorDescription: String?)
    }
}

// MARK: - NetworkErrors

extension AppError.Enums.NetworkErrors: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .cantGetURLRequest:
            return "Can't get url request for this path"
        case .cantGetData:
            return "Can't get data"
        case .cantDecodeResult:
            return "Can't decode data from backend"
        case .someBackendError:
            return "We have some error on our side, we trying to fix that already!"
        case .custom(_, let errorDescription):
            return errorDescription
        }
    }

    var errorCode: Int? {
        switch self {
        case .cantGetURLRequest:
            return AppErrorCode.cantGetURLRequest
        case .cantGetData:
            return AppErrorCode.cantGetData
        case .cantDecodeResult:
            return AppErrorCode.cantDecodeResult
        case .someBackendError(let errorCode), .custom(let errorCode, _):
            return errorCode
        }
    }
}
