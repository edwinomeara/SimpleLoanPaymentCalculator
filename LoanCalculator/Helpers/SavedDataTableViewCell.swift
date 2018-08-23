//
//  SavedDataTableViewCell.swift
//  LoanCalculator
//
//  Created by Edwin  O'Meara on 7/2/18.
//  Copyright © 2018 Edwin  O'Meara. All rights reserved.
//

import UIKit

class SavedDataTableViewCell: UITableViewCell {


    @IBOutlet weak var cellBackground: UIView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var loan: UILabel!
    @IBOutlet weak var interest: UILabel!
    @IBOutlet weak var paymentFrequency: UILabel!
    @IBOutlet weak var loanDuration: UILabel!
    @IBOutlet weak var additionalPayment: UILabel!
    @IBOutlet weak var name: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
