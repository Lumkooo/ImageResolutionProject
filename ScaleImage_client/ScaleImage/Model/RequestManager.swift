//
//  RequestManager.swift
//  ScaleImage
//
//  Created by Андрей Шамин on 8/7/22.
//

import Foundation

typealias Parameters = [String: Any]
typealias RequestResult = (Result<Data, AppError.Enums.NetworkErrors>) -> Void

final class RequestManager {
    private let timeoutInterval: TimeInterval = 1000
    private let requestManagerBackgroundQueue = DispatchQueue(label: "RequestManagerQueue",
                                                              qos: .userInitiated,
                                                              attributes: .concurrent)

    func perform(path: ServerPath,
                 httpMethod: HTTPMethod = .get,
                 parameters: Parameters? = nil,
                 completion: RequestResult?) {
        guard let request = getRequest(for: path.stringPath, httpMethod: httpMethod, parameters: parameters) else {
            completion?(.failure(.cantGetURLRequest))
            return
        }
        
        requestManagerBackgroundQueue.async {
            let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
                let httpURLResponse = response as? HTTPURLResponse
                let statusCode = httpURLResponse?.statusCode ?? 0
                if let error = error {
                    completion?(.failure(.custom(errorCode: statusCode, errorDescription: error.localizedDescription)))
                    return
                }
                
                guard statusCode < 400 else {
                    completion?(.failure(.someBackendError(errorCode: statusCode)))
                    return
                }
                
                guard let data = data else {
                    completion?(.failure(.cantGetData))
                    return
                }
                
                completion?(.success(data))
            }
            dataTask.resume()
        }
    }
}

// MARK: - Private

private extension RequestManager {
    func getRequest(for path: String,
                    httpMethod: HTTPMethod,
                    parameters: Parameters?) -> URLRequest? {
        guard let url = getURL(for: path) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.stringValue
        request.timeoutInterval = timeoutInterval
        if let parameters = parameters {
            request.httpBody = parameters.percentEncoded()
        }
        return request
    }

    func getURL(for path: String) -> URL? {
        var defaultURL = getDefaultURL()
        defaultURL?.appendPathComponent(path)
        return defaultURL
    }

    func getDefaultURL() -> URL? {
        let mainDomain = ServerInfo.mainDomain
        let defaultURL = URL(string: mainDomain)
        return defaultURL
    }
}
