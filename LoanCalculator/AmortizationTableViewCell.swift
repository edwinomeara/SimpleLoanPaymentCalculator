//
//  AmortizationTableViewCell.swift
//  LoanCalculator
//
//  Created by Edwin  O'Meara on 6/26/18.
//  Copyright © 2018 Edwin  O'Meara. All rights reserved.
//

import UIKit

class AmortizationTableViewCell: UITableViewCell {
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var interest: UILabel!
    @IBOutlet weak var principle: UILabel!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var cellViewTwo: UIView!
    @IBOutlet weak var cellViewOne: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
