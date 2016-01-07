//
//  DataInitializer.swift
//
//  Created by Charles Augustine.
//  Copyright (c) 2015 Charles Augustine. All rights reserved.
//


import CoreData
import Foundation


public protocol DataInitializer {
	func initializeDataForNewStoreInContext(context: NSManagedObjectContext)
}