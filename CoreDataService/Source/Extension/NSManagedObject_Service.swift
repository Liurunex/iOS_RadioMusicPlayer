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
			if let success = managedObjectContext?.obtainPermanentIDsForObjects([self]) where success {
				result = objectID
			}
			else {
				print("Error obtaining permanent object ID for object \(self)\n\(error)")
			}
		}

		return result
	}
}