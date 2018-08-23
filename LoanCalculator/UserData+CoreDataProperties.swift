//
//  UserData+CoreDataProperties.swift
//  LoanCalculator
//
//  Created by Edwin  O'Meara on 6/26/18.
//  Copyright © 2018 Edwin  O'Meara. All rights reserved.
//
//

import Foundation
import CoreData


extension UserData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserData> {
        return NSFetchRequest<UserData>(entityName: "UserData")
    }

    @NSManaged public var date: Date//String//NSDate // ? there was a question mark after NSDate
    @NSManaged public var downPayment: Double
    @NSManaged public var interestFinal: Double
    @NSManaged public var interestRate: Double
    @NSManaged public var loan: Double
    @NSManaged public var months: Int16
    @NSManaged public var paymentFinal: Double
    @NSManaged public var paymentFrequency: Int16
    @NSManaged public var totalFinal: Double
    @NSManaged public var years: Int16

}
