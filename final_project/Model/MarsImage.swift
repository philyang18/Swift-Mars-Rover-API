//
//  MarsImage.swift
//  final_project
//
//  Created by Phillip Yang on 4/25/19.
//  Copyright © 2019 Phillip Yang. All rights reserved.
//

import Foundation

struct MarsImage:Equatable {
    
    private(set) var imageUrl: String!
    private(set) var imageID: Int!
    
    func getUrl() -> String {
        return imageUrl
    }
    
    func getID() -> Int {
        return imageID
    }
    init(url: String, id: Int) {
        imageUrl = url
        imageID = id
    }
}
