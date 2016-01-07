//
//  User.swift
//  FinalProject
//
//  Created by Runex on 8/5/15.
//
//

import Foundation
import CoreData

class User: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var photo: NSData

}
