//
//  Song.swift
//  FinalProject
//
//  Created by Runex on 8/5/15.
//
//

import Foundation
import CoreData

class Song: NSManagedObject {

    @NSManaged var url: String
    @NSManaged var image: String
    @NSManaged var title: String
    @NSManaged var artist: String
    @NSManaged var company: String
    @NSManaged var albumtitle: String
    @NSManaged var public_time: String
}
