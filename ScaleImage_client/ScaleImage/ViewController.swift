//
//  ViewController.swift
//  ScaleImage
//
//  Created by Андрей Шамин on 8/6/22.
//

import UIKit

final class ViewController: UIViewController {

    @IBOutlet private var bottomImageViewLoader: UIActivityIndicatorView?
    @IBOutlet private var bottomImageView: UIImageView?
    @IBOutlet private var topImageView: UIImageView?
    @IBOutlet private var sendButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSendButton()
        setupTopImageView()
    }
}

// MARK: - Private

private extension ViewController {
    func setupTopImageView() {
        topImageView?.image = UIImage(named: "income_image")
    }

    func setupSendButton() {
        sendButton?.setTitle("Send it!", for: .normal)
        sendButton?.addTarget(self,
                              action: #selector(sendButtonTapped),
                              for: .touchUpInside)
    }

    @objc func sendButtonTapped() {
        guard let url = URL(string: "http://localhost:8080/"),
              let image = topImageView?.image,
              let imageData = image.pngData() else {
            return
        }
        bottomImageView?.image = nil
        bottomImageViewLoader?.startAnimating()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let parameters: [String: String] = [
            "image_data": imageData.base64EncodedString()
        ]
        request.timeoutInterval = 10000000
        request.httpBody = parameters.percentEncoded()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let jsonDecoder = JSONDecoder()
                guard let imageData = try? jsonDecoder.decode(ImageData.self, from: data) else {
                    return
                }

                if let imgData = imageData.image,
                   let image = UIImage(data: imgData) {
                    DispatchQueue.main.async {
                        self.bottomImageView?.image = image
                    }
                }
            }

            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            }

            DispatchQueue.main.async {
                self.bottomImageViewLoader?.stopAnimating()
            }
        }
        task.resume()
    }
}


extension Dictionary {
    func percentEncoded() -> Data? {
        map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed: CharacterSet = .urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}


struct ImageData: Codable {
    let image: Data?
    let other_key: String?
}

