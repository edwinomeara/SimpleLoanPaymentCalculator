//
//  SavedData+CoreDataProperties.swift
//  LoanCalculator
//
//  Created by Edwin  O'Meara on 7/4/18.
//  Copyright © 2018 Edwin  O'Meara. All rights reserved.
//
//

import Foundation
import CoreData


extension SavedData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedData> {
        return NSFetchRequest<SavedData>(entityName: "SavedData")
    }

    @NSManaged public var dateSaved: Date
    @NSManaged public var downPaymentSaved: Double
    @NSManaged public var interestFinalSaved: Double
    @NSManaged public var interestRateSaved: Double
    @NSManaged public var loanSaved: Double
    @NSManaged public var monthsSaved: Int16
    @NSManaged public var name: String
    @NSManaged public var paymentFrequencySaved: Int16
    @NSManaged public var paymentSavedFinal: Double
    @NSManaged public var totalSavedFinal: Double
    @NSManaged public var yearsSaved: Int16

}
