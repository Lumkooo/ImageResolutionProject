//
//  ServerManager.swift
//  ScaleImage
//
//  Created by Андрей Шамин on 8/7/22.
//

import Foundation
import UIKit


typealias ImageCompletion = (Result<UIImage?, AppError.Enums.NetworkErrors>) -> Void

final class ServerManager {
    private let requestManager = RequestManager()
    private let mainQueue = DispatchQueue.main

    func scaleImage(image: UIImage?, completion: ImageCompletion?) {
        guard let image = image,
              let imageData = image.pngData() else {
            return
        }
        
        let parameters: [String: String] = [
            "image_data": imageData.base64EncodedString()
        ]
        requestManager.perform(path: .scaleImagePath,
                               httpMethod: .post,
                               parameters: parameters) { [weak self] result in
            self?.mainQueue.async {
                switch result {
                case .success(let data):
                    let jsonDecoder = JSONDecoder()
                    guard let imageDataInfo = try? jsonDecoder.decode(ImageDataInfo.self, from: data), let imageData = imageDataInfo.image else {
                        completion?(.failure(.cantDecodeResult))
                        return
                    }
                    let image = UIImage(data: imageData)
                    completion?(.success(image))
                case .failure(let error):
                    completion?(.failure(error))
                }
            }
        }
    }
}
