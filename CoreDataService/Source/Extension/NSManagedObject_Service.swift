//
//  NSManagedObject_Service.swift
//
//  Created by Charles Augustine.
//  Copyright (c) 2015 Charles Augustine. All rights reserved.
//


import CoreData
import Foundation


public extension NSManagedObject {
	public var permanentObjectID: NSManagedObjectID? {
		var result: NSManagedObjectID?
		if !objectID.temporaryID {
			result = objectID
		}
		else {
			let error: NSError?
            do{
                if let success = try managedObjectContext?.obtainPermanentIDsForObjects([self]){
                    result = objectID
                }
                else {
                    print("Error")
                }
            }
            catch _{
                print("haha")
            }
		}

		return result
	}
}