//
//  UITableViewExtensions.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2020. 02. 21..
//  Copyright © 2020. Foltányi Kolos. All rights reserved.
//

import UIKit

extension UITableView {
    func dequeuCellOfType<Cell: UITableViewCell>(_ type: Cell.Type, id: String? = nil) -> Cell {
        let reuseIdentifier = id ?? Cell.identifier
        
        guard let cell = dequeueReusableCell(withIdentifier: reuseIdentifier) as? Cell else {
            fatalError("Could not dequeue cell with identifier: \(reuseIdentifier)")
        }
        
        return cell
    }
    
    func register<Cell: UITableViewCell>(_ type: Cell.Type, id: String? = nil) {
        let reuseIdentifier = id ?? Cell.identifier
        register(type, forCellReuseIdentifier: reuseIdentifier)
    }
    
    var indexPaths: [IndexPath] {
        var result = [IndexPath]()
        for section in 0 ..< numberOfSections {
            for row in 0 ..< numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                result.append(indexPath)
            }
        }
        return result
    }
}
