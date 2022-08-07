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
    private let serverManager = ServerManager()

    private let animationDuration: Double = 0.3

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

    func testRequest() {
        let request = RequestManager()
        request.perform(path: .testGet) { result in
            switch result {
            case .failure(let error):
                print("ERORR: \(error)")
            case .success(let data):
                print(String(data: data, encoding: .utf8))
            }
        }
    }

    @objc func sendButtonTapped() {
        let image = topImageView?.image

        UIView.animate(withDuration: animationDuration) {
            self.bottomImageView?.alpha = 0
        } completion: { _ in
            self.bottomImageView?.image = nil
        }
        bottomImageViewLoader?.startAnimating()
        serverManager.scaleImage(image: image) { [weak self] result in
            guard let self = self else {
                return
            }
            self.bottomImageViewLoader?.stopAnimating()
            switch result {
            case .failure(let error):
                // TODO: - Show error
                print("ERROR: \(error.errorDescription)")
                return
            case .success(let image):
                UIView.animate(withDuration: self.animationDuration) {
                    self.bottomImageView?.alpha = 1
                }
                self.bottomImageView?.image = image
            }
        }
    }
}
