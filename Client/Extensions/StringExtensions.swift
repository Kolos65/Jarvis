//
//  StringExtensions.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 14..
//

import Foundation
import Security

extension String {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
    
    static func random(length: Int) -> String {
        let chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._"
        var result = ""
        for _ in 0..<length {
            var random: UInt8 = 0
            var bytes = [Int8](repeating: 0, count: 1)
            let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
            guard status == errSecSuccess else {
                fatalError("Could not generate random string securely!")
            }
            NSData(bytes: bytes, length: bytes.count).getBytes(&random, length: bytes.count)
            let index = Int(random % 64) // No modulo bias because rand_max % n = n - 1 (255 % 64 = 63)
            result.append(chars[index])
            
        }
        return result
    }
}

