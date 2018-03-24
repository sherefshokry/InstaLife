//
//  Photo.swift
//  InstaLife
//
//  Created by SherifShokry on 3/18/18.
//  Copyright © 2018 SherifShokry. All rights reserved.
//

import Foundation
import UIKit
class Photo
{

    var id : String?
    var server : String?
    var farm : String?
    var secret : String?
    var photo : UIImage?
    init(id : String , server : String , farm : String , secret : String){
        self.id = id
        self.server = server
        self.farm = farm
        self.secret = secret
        
    }
    
    func addPhoto(photo : UIImage)
    {
        self.photo = photo
    }
    
    
    
}
