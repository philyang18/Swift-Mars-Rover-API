//
//  MarsImagesModel.swift
//  final_project
//
//  Created by Phillip Yang on 4/25/19.
//  Copyright © 2019 Phillip Yang. All rights reserved.
//

import Foundation


// CONSTANTS aka keys
let IMAGES_KEY = "images"
let URL_KEY = "url"
let ID_KEY = "id"

class MarsImagesModel: MarsImagesDataModel {
    
    // variables
    private var images = [MarsImage]()
    private(set) var currentIndex = 0
    private var fileName: String?
    
    // retrieves data from a saved file
    init() {
        
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        fileName =  "\(documentsDirectory)/quotes.plist"
        
        if let imagesArrayOfDictionaries = NSArray(contentsOfFile: fileName!) as? [[String: String]] {
            images = []
            for imageDictionary in imagesArrayOfDictionaries {
                let image = MarsImage(url: imageDictionary[URL_KEY]!, id: Int(imageDictionary[ID_KEY]!)!)
                images.append(image)
            }
        }
    }
    
    // creates a singleton model
    static let sharedInstance = MarsImagesModel()
    
    
    // retrieves the number of MarsImages in the "images" array
    func numberOfImages() -> Int {
        return images.count
    }
    
    // retrieves a MarsImage at the given index
    func image(atIndex: Int, setCurrIndex: Bool) -> MarsImage? {
        if setCurrIndex {
            if (atIndex >= 0 && atIndex < numberOfImages()) {
                currentIndex = atIndex
                return images[currentIndex]
            }
            else {
                return nil
            }
        }
        else {
            return images[atIndex]
        }
    }

    // appends a new MarsImage onto the array of MarsImages
    func insert(url: String, id: Int) {
        let newImage = MarsImage(url: url, id: id)
        images.append(newImage)
        save()
    }
    
    // removes the last item of the images array
    func removeImage() {
        if (numberOfImages() > 0) {
            if (currentIndex == numberOfImages() - 1) {
                currentIndex = 0
            }
            images.removeLast()
        }
        save()
    }
    
    // removes the item at the given index from the array of MarsIamges
    func removeImage(atIndex: Int) {
        if (numberOfImages() > 0 && atIndex >= 0 && atIndex < numberOfImages()) {
            if (currentIndex == numberOfImages() - 1) {
                removeImage()
            }
            else {
                if (atIndex < currentIndex) {
                    currentIndex -= 1
                }
                images.remove(at: atIndex)
            }
        }
        save()
    }
    
    // converts each image from the images array into a dictionary to be stored in a file
    func save() {
        var savedImagesArray = [[String: String]]()
        for image in images {
            let imageDictionary = [
                URL_KEY: image.getUrl(),
                ID_KEY: String(image.getID())
            ]
            savedImagesArray.append(imageDictionary)
        }
        (savedImagesArray as NSArray).write(toFile: fileName!, atomically: true)

    }
    
    
    //    func insert(url: String, id: Int, atIndex: Int) {
    //        if (atIndex >= 0 && atIndex <= numberOfImages()) {
    //            if (atIndex <= currentIndex) {
    //                currentIndex += 1;
    //            }
    //            let newImage = MarsImage(url: url, id: id)
    //            images.insert(newImage, at: atIndex)
    //        }
    //    }
    //    func nextImage() -> MarsImage? {
    //        if numberOfImages() <= 0 {
    //            return nil
    //        }
    //        else {
    //            if currentIndex == numberOfImages() - 1 {
    //                currentIndex = 0
    //            }
    //            else {
    //                currentIndex += 1
    //            }
    //            return images[currentIndex]
    //        }
    //    }
    //
    //    func prevImage() -> MarsImage? {
    //        if numberOfImages() <= 0 {
    //            return nil
    //        }
    //        else {
    //            if currentIndex == 0 {
    //                currentIndex = numberOfImages() - 1
    //            }
    //            else {
    //                currentIndex -= 1
    //            }
    //            return images[currentIndex]
    //        }
    //    }
}
