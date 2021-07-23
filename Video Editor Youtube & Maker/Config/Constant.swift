//
//  Constant.swift
//  ZipAlbum
//
//  Created by Nhuom Tang on 16/9/19.
//  Copyright © 2019 Nhuom Tang. All rights reserved.
//

import UIKit

typealias AppResult = Result

let PER_PAGE = 21

//VALUE
let DEVICE_WIDTH = UIScreen.main.bounds.width
let DEVICE_HEIGHT = UIScreen.main.bounds.height
let scale = DEVICE_WIDTH / 414
let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad
let IS_PHONE = UIDevice.current.userInterfaceIdiom == .phone


