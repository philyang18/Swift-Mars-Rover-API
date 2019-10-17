//
//  MarsImagesDataModel.swift
//  final_project
//
//  Created by Phillip Yang on 4/25/19.
//  Copyright © 2019 Phillip Yang. All rights reserved.
//

import Foundation

protocol MarsImagesDataModel {
    func numberOfImages() -> Int
    func image(atIndex: Int, setCurrIndex:Bool) -> MarsImage?
//    func nextImage() -> MarsImage?
//    func prevImage() -> MarsImage?
    func insert(url: String, id: Int)
//    func insert(url: String, id: Int, atIndex: Int)
    func removeImage()
    func removeImage(atIndex: Int)
}
