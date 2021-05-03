//
//  EventViewModel.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 16..
//

import UIKit

struct EventViewModel: HomeListViewModel {
    var title: String
    var subtitle: String
    var dateString: String
    var icon: UIImage?
    
    init(from event: Event) {
        let epoch = Double(event.time)
        let date = Date(timeIntervalSince1970: epoch)
        let dateFromatter = DateFormatter()
        dateFromatter.dateFormat = "EEEE, HH:mm"
        title = dateFromatter.string(from: date)
        dateFromatter.dateFormat = "YYYY. MM. dd."
        dateString = dateFromatter.string(from: date)
        subtitle = event.title
        let motionIcon = UIImage(named: "eye_icon_filled")
        let faceIcon = UIImage(named: "face_icon_filled")
        icon = event.type == "motion" ? motionIcon : faceIcon
        if event.name == "Obama" {
            icon = UIImage(named: "obama")
        }
    }
}
