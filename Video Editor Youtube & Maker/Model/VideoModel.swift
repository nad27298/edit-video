//
//  VideoModel.swift
//  Video Editor Youtube & Maker
//
//  Created by nguyenhuyson2 on 1/9/21.
//

import UIKit
import Photos

class VideoModel {
    
    var id: Int = 0
    var name: String = ""
    var url: String = ""
    var date: String = ""
    
    init(id: Int, name: String, url: String, date: String) {
        self.id = id
        self.name = name
        self.url = url
        self.date = date
    }
}
