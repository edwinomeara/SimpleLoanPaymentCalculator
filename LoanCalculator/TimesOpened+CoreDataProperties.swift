//
//  TimesOpened+CoreDataProperties.swift
//  LoanCalculator
//
//  Created by Edwin  O'Meara on 7/4/18.
//  Copyright © 2018 Edwin  O'Meara. All rights reserved.
//
//

import Foundation
import CoreData


extension TimesOpened {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TimesOpened> {
        return NSFetchRequest<TimesOpened>(entityName: "TimesOpened")
    }

    @NSManaged public var count: Int16

}
