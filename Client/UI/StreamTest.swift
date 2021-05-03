//
//  ViewController.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2020. 12. 21..
//

import UIKit
import Foundation


class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    private let url = URL(string: "http://http://raspi-ip:5000/stream")!
    private lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    private lazy var dataTask = session.dataTask(with: url)
    
    private var nextImage = Data()
    
    override func viewDidLoad() {
        dataTask.resume()
    }
}

extension ViewController: URLSessionDataDelegate {
    
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        let image = UIImage(data: nextImage)
        DispatchQueue.main.async {
            self.imageView.image = image
        }
        self.nextImage = Data()
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        nextImage.append(data)
    }
}
