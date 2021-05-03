//
//  ChildCoordinator.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2019. 08. 11..
//  Copyright © 2019. Foltányi Kolos. All rights reserved.
//

import UIKit

protocol ChildCoordinator: Coordinator {
    var parentCoordinator: Coordinator? { get set }
}
