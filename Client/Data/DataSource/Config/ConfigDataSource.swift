//
//  ConfigDataSource.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 17..
//

protocol ConfigDataSource: DataSource {
    func resetMotionDetector(token: String, completion: @escaping (ResetResponse?, DataSourceError?) -> Void)
    func setMotionDetector(request: DetectorRequest, token: String, completion: @escaping (DetectorResponse?, DataSourceError?) -> Void)
    func setFaceRecognition(request: RecognizerRequest, token: String, completion: @escaping (RecognizerResponse?, DataSourceError?) -> Void)
    func getMotionDetector(token: String, completion: @escaping (DetectorResponse?, DataSourceError?) -> Void)
    func getFaceRecognition(token: String, completion: @escaping (RecognizerResponse?, DataSourceError?) -> Void)
}
