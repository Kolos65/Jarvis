//
//  VideoImageView.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 16..
//

import UIKit

class VideoImageView: UIImageView {
    private enum Constants {
        static let authorization = "Authorization"
    }
    var url: URL?
    var token: String?
    
    private lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    private var dataTask: URLSessionDataTask?
    private var nextImage = Data()
    
    func start() {
        guard let url = url, let token = token else { return }
        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: Constants.authorization)
        if dataTask == nil {
            dataTask = session.dataTask(with: request)
        }
        dataTask?.resume()
    }
    
    func stop() {
        dataTask?.cancel()
    }
}

extension VideoImageView: URLSessionDataDelegate {
    func urlSession(_ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        
        let image = UIImage(data: nextImage)
        DispatchQueue.main.async {
            self.image = image
        }
        self.nextImage = Data()
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        nextImage.append(data)
    }
}

