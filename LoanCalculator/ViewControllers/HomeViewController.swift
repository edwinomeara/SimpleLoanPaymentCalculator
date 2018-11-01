

import UIKit
import TextFieldEffects
import Foundation
import CoreData

class HomeViewController: UIViewController, UIScrollViewDelegate,  UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    var count = 0
    var presentDataList = [UserData]()
    var savedDataList = [SavedData]()

 
    @IBOutlet weak var errorLabel: UILabel!
    var paymentFrequency = Int()
    let yearArray = [Int](0...100)
    let monthArray = [Int](0...60)
    @IBOutlet weak var dpBackgroundButton: UIButton!
    @IBOutlet weak var dpErrorConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundButton: UIButton!
    @IBOutlet weak var errorViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var savenameBackgroundButton: UIButton!
    @IBOutlet weak var savedNameConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveNameView: UIView!
    @IBOutlet weak var savedNameButton: UIButton!
    @IBOutlet weak var savedNameText: UITextField!
    @IBOutlet weak var gradientBackgroundView: UIView!
    @IBOutlet weak var dpErrorView: UIView!
    @IBOutlet weak var dpErrorButton: UIButton!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    var monthChosen = HoshiTextField()
    var yearChosen = HoshiTextField()
    var interestText = HoshiTextField()
    var loanText = HoshiTextField()
    var extraPaymentText = HoshiTextField()
    var month = Int()
    var year = Int()
    var loan = String()
    var interest = String()
    @IBOutlet weak var yearlyButton: UIButton!
    var yearlyButtonCenter: CGPoint!
    @IBOutlet weak var quarterlyButton: UIButton!
    var quarterlyButtonCenter: CGPoint!
    @IBOutlet weak var monthlyButton: UIButton!
    var monthlyButtonCenter: CGPoint!
    @IBOutlet weak var paymentFrequencyButton: UIButton!
    @IBOutlet weak var durationButton: UIButton!
    var durationButtonCenter: CGPoint!
    @IBOutlet weak var downPaymentView: UIView!
    @IBOutlet weak var loanAmountView: UIView!
    @IBOutlet weak var interestRateView: UIView!
    @IBOutlet weak var yearView: UIView!
    var yearViewCenter: CGPoint!
    @IBOutlet weak var monthView: UIView!
    var monthViewCenter: CGPoint!
    var yearPicker = UIPickerView()
    var monthPicker = UIPickerView()
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var totalPaidLabel: UILabel!
    var name = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchRequest: NSFetchRequest<UserData> = UserData.fetchRequest()
        do {
            let dataList = try PersistenceService.context.fetch(fetchRequest)
            presentDataList = dataList
        } catch {}
        setViews()
        reloadData(data: presentDataList)
    }
    
    
    // -------------------------Core Data Stuff -------------------------------
    
    
    func reloadData(data: [UserData]){
        if data.count < 1 {
            return
        }
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.currencyAccounting
        loanText.text = numberFormatter.string(from: NSNumber(value: data[0].loan))
        interestText.text = "\(data[0].interestRate)%"
        yearChosen.text = String(data[0].years)
        monthChosen.text = String(data[0].months)
        extraPaymentText.text = numberFormatter.string(from: NSNumber(value: data[0].downPayment))
        
        if data[0].paymentFrequency == 12 {
            monthlyButton.backgroundColor = #colorLiteral(red: 0.2196078431, green: 0.9764705882, blue: 0.9450980392, alpha: 1)
            monthlyButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        }
        else if data[0].paymentFrequency == 4 {
            quarterlyButton.backgroundColor = #colorLiteral(red: 0.2196078431, green: 0.9764705882, blue: 0.9450980392, alpha: 1)
            quarterlyButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        }
        else {
            yearlyButton.backgroundColor = #colorLiteral(red: 0.2196078431, green: 0.9764705882, blue: 0.9450980392, alpha: 1)
            yearlyButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        }
        donePressed()
        durationButtonOpened()
        paymentFrequencyButtonOpened()
    }
    
    func saveDataForNow(totalFinal: Double, paymentFinal: Double, interestFinal: Double, loan: Double, interestRate: Double, years: Int, months: Int, paymentFrequency: Int, extraPayment: Double) {
        deletePresentData()
        let userData = UserData(context: PersistenceService.context)
        userData.date = getDate()
        userData.totalFinal = totalFinal
        userData.paymentFinal = paymentFinal
        userData.interestFinal = interestFinal
        userData.loan = loan
        userData.interestRate = interestRate
        userData.years = Int16(years)
        userData.months = Int16(months)
        userData.downPayment = extraPayment
        userData.paymentFrequency = Int16(paymentFrequency)
        PersistenceService.saveContext()
        presentDataList.append(userData)
    }
    
    func getDate() -> Date{
        if presentDataList.count == 0 {
            return Date()
        } else {
            return presentDataList[0].date
        }
    }
    
    func deletePresentData(){
        do {
            try PersistenceService.context.execute(NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "UserData")))
            PersistenceService.saveContext()
        } catch{}
    }
    
    //Resets all input values 
    @IBAction func resetTapped(_ sender: Any) {
        deletePresentData()
        loanText.text = ""
        interestText.text = ""
        yearChosen.text = ""
        monthChosen.text = ""
        extraPaymentText.text = ""
        paymentLabel.text = "$0.00"
        interestLabel.text = "$0.00"
        totalPaidLabel.text = "$0.00"
        paymentFrequencyButtonClosed()
        durationButtonClosed()
        yearlyButton.backgroundColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 1)
        monthlyButton.backgroundColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 1)
        quarterlyButton.backgroundColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 1)
        yearlyButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        quarterlyButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        monthlyButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
    }
    
    //--------------------------- PickerView ------------------------
    func createYearPicker(_ textField : UITextField){
        yearPicker.tag = 1
        yearPicker.delegate = self
        yearPicker.dataSource = self
        yearChosen.inputView = yearPicker
        textField.inputAccessoryView = createToolBar()
    }
    
    func createMonthPicker(_ textField: UITextField){
        monthPicker.delegate = self
        monthPicker.dataSource = self
        monthChosen.inputView = monthPicker
        textField.inputAccessoryView = createToolBar()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            year = yearArray[row]   // get the year value here
            yearChosen.text = String(yearArray[row])
        } else {
            month = monthArray[row] // get month value here
            monthChosen.text = String(monthArray[row])
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return yearArray.count
        } else {
            return monthArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return String(yearArray[row])
        } else {
            return String(monthArray[row])
        }
    }
    
    //--------------------------Buttons/HoshiText/toolbar-----------------------
    //TextfieldEffects used with custom colors and sizes.  Also allows movement of texfields
    @IBAction func durationClicked(_ sender: Any) {
        if durationButton.backgroundColor == #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) {
            durationButtonOpened()
        }else{
            durationButtonClosed()
        }
    }
    
    func durationButtonOpened(){
        UIView.animate(withDuration: 0.4, animations: {
            self.yearView.alpha = 1
            self.monthView.alpha = 1
            self.yearView.center = self.yearViewCenter
            self.monthView.center = self.monthViewCenter
            self.durationButton.backgroundColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
        })
    }
    
    func durationButtonClosed(){
        durationButton.backgroundColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
        UIView.animate(withDuration: 0.4, animations: {
            self.yearView.alpha = 0
            self.monthView.alpha = 0
            self.yearView.center = CGPoint(x: 187, y: -50)
            self.monthView.center = CGPoint(x: 187, y: -50)
            self.durationButton.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        })
    }
    
    @IBAction func paymentFrequencyClicked(_ sender: Any) {
        if paymentFrequencyButton.backgroundColor == #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) {
            paymentFrequencyButtonOpened()
        }else{
            paymentFrequencyButtonClosed()
        }
    }
    
    func paymentFrequencyButtonOpened() {
        UIView.animate(withDuration: 0.4, animations: {
            self.monthlyButton.alpha = 1
            self.quarterlyButton.alpha = 1
            self.yearlyButton.alpha = 1
            self.monthlyButton.center = self.monthlyButtonCenter
            self.quarterlyButton.center = self.quarterlyButtonCenter
            self.yearlyButton.center = self.yearlyButtonCenter
            self.paymentFrequencyButton.backgroundColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
        })
    }
    
    func paymentFrequencyButtonClosed(){
        paymentFrequencyButton.backgroundColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
        UIView.animate(withDuration: 0.4, animations:{
            self.monthlyButton.alpha = 0
            self.quarterlyButton.alpha = 0
            self.yearlyButton.alpha = 0
            self.monthlyButton.center = CGPoint(x: 187, y: -20)
            self.quarterlyButton.center = CGPoint(x: 187, y: -20)
            self.yearlyButton.center = CGPoint(x: 187, y: -20)
            self.paymentFrequencyButton.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        })
    }
    
    @IBAction func monthlyTapped(_ sender: Any) {
        paymentFrequency = 12
        getValues()
        findIfDivisible()
        
        //checks if the backgrounds of the button is a certain color and if it is pressed changes to a different color
        if monthlyButton.backgroundColor == #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 1) {
            monthlyButton.backgroundColor = #colorLiteral(red: 0.2196078431, green: 0.9764705882, blue: 0.9450980392, alpha: 1)
            monthlyButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            yearlyButton.backgroundColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 1)
            quarterlyButton.backgroundColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 1)
            yearlyButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
            quarterlyButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        }
    }
    
    @IBAction func quarterlyTapped(_ sender: Any) {
        paymentFrequency = 4
        getValues()
        findIfDivisible()
        
         //checks if the backgrounds of the button is a certain color and if it is pressed changes to a different color
        if quarterlyButton.backgroundColor == #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 1) {
            quarterlyButton.backgroundColor = #colorLiteral(red: 0.2196078431, green: 0.9764705882, blue: 0.9450980392, alpha: 1)
            quarterlyButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            yearlyButton.backgroundColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 1)
            monthlyButton.backgroundColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 1)
            yearlyButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
            monthlyButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        }
    }
    
    @IBAction func yearlyTapped(_ sender: Any) {
        paymentFrequency = 1
        getValues()
        findIfDivisible()
        
         //checks if the backgrounds of the button is a certain color and if it is pressed changes to a different color
        if yearlyButton.backgroundColor == #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 1)  {
            yearlyButton.backgroundColor = #colorLiteral(red: 0.2196078431, green: 0.9764705882, blue: 0.9450980392, alpha: 1)
            yearlyButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            monthlyButton.backgroundColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 1)
            quarterlyButton.backgroundColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 1)
            quarterlyButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
            monthlyButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        }
    }
    
    func setYearsView(){
        yearChosen = HoshiTextField(frame: CGRect(x: 0, y: 0, width: yearView.frame.width, height: yearView.frame.height))
        yearChosen.tag = 5
        setHoshiTextField(text: yearChosen)
    }
    
    func setMonthsView() {
        monthChosen = HoshiTextField(frame: CGRect(x: 0, y: 0, width: yearView.frame.width, height: yearView.frame.height))
        monthChosen.tag = 4
        setHoshiTextField(text: monthChosen)
    }
    
    func setInterestRateView() {
        interestText = HoshiTextField(frame: CGRect(x: 18, y: 0, width: interestRateView.frame.width - 40, height: 70))
        interestText.tag = 1
        setHoshiTextField(text: interestText)
    }
    
    func setLoanAmountView() {
        loanText = HoshiTextField(frame: CGRect(x: 18, y: 0, width: loanAmountView.frame.width - 40, height: 70))
        loanText.tag = 2
        setHoshiTextField(text: loanText)
    }
    
    func setextraPaymentAmountView() {
        extraPaymentText = HoshiTextField(frame: CGRect(x: 18, y: 0, width:  downPaymentView.frame.width - 40, height: 70))
        extraPaymentText.tag = 3
        setHoshiTextField(text: extraPaymentText)
    }
    
    func setHoshiTextField(text: HoshiTextField) {
        text.placeholderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        text.borderActiveColor = #colorLiteral(red: 0.2196078431, green: 0.9764705882, blue: 0.9450980392, alpha: 1)
        text.borderInactiveColor = #colorLiteral(red: 0.2196078431, green: 0.9764705882, blue: 0.9450980392, alpha: 1)
        text.placeholderFontScale = 1.5
        text.textAlignment = .center
        text.textColor = #colorLiteral(red: 0.2196078431, green: 0.9764705882, blue: 0.568627451, alpha: 1)
        text.inputAccessoryView = createToolBar()

        if text.tag == 1{
            text.placeholder = "Interest Rate"
            text.addTarget(self, action: #selector(interestRateTextFieldChange), for: .editingChanged)
            text.keyboardType = .numberPad
            interestRateView.addSubview(text)
        }
        if text.tag == 2{
            loanText.placeholder = "Loan Amount"
            loanText.addTarget(self, action: #selector(loanTextFieldChange), for: .editingChanged)
            text.keyboardType = .numberPad
            loanAmountView.addSubview(text)
        }
        if text.tag == 3 {
            text.placeholderFontScale = 1.3
            text.placeholder = "Additional Payment Per Term"
            text.addTarget(self, action: #selector(loanTextFieldChange), for: .editingChanged)
            text.keyboardType = .numberPad
            downPaymentView.addSubview(text)
        }
        if text.tag == 4 {
            createMonthPicker(monthChosen)
            text.placeholder = "Months"
            text.keyboardType = .decimalPad
            monthView.addSubview(text)
        }
        if text.tag == 5 {
            createYearPicker(yearChosen)
            yearChosen.placeholder = "Years"
            yearChosen.keyboardType = .decimalPad
            yearView.addSubview(text)
        }

    }
    //sets corner radius, color, border width, and positions
    func setViews(){
        
        savedNameText.inputAccessoryView = createToolBar()
        
        saveNameView.layer.cornerRadius = 15
        savedNameButton.layer.cornerRadius = 15
        savedNameButton.layer.borderWidth = 1
        savedNameButton.layer.borderColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
        
        yearViewCenter = yearView.center
        monthViewCenter = monthView.center
        yearView.center = CGPoint(x: 187, y: -50)
        monthView.center = CGPoint(x: 187, y: -50)
        
        yearlyButtonCenter = yearlyButton.center
        quarterlyButtonCenter = quarterlyButton.center
        monthlyButtonCenter = monthlyButton.center
        
        monthlyButton.center = CGPoint(x: 187, y: -20)
        quarterlyButton.center = CGPoint(x: 187, y: -20)
        yearlyButton.center = CGPoint(x: 187, y: -20)
        
        monthlyButton.layer.cornerRadius = 15
        quarterlyButton.layer.cornerRadius = 15
        yearlyButton.layer.cornerRadius = 15
        paymentFrequencyButton.layer.cornerRadius = 20
        durationButton.layer.cornerRadius = 20
        
        errorView.layer.cornerRadius = 15
        
        errorButton.layer.borderWidth = 1
        errorButton.layer.cornerRadius = 15
        errorButton.layer.borderColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
        
        dpErrorView.layer.cornerRadius = 15
        
        dpErrorButton.layer.borderColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
        dpErrorButton.layer.cornerRadius = 15
        dpErrorButton.layer.borderWidth = 1
        
        setInterestRateView()
        setLoanAmountView()
        setextraPaymentAmountView()
        setYearsView()
        setMonthsView()
    }
    
    func createToolBar() -> UIToolbar{
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        //done moved over to right side of toolbar
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }
    //---------------------------- ErrorPopups ------------------------------------
    
    @IBAction func dismissPopUp(_ sender: Any) {
        errorViewConstraint.constant = 1000
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
            self.backgroundButton.alpha = 0
            self.monthChosen.text = "0"
            self.yearChosen.text = "0"
            self.donePressed()
        })
    }
    
    @IBAction func dpDismissPopUP(_ sender: Any) {
        dpErrorConstraint.constant = 1000
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
            self.dpBackgroundButton.alpha = 0
            self.extraPaymentText.text = "$0.00"
            self.donePressed()
        })
    }
    
    @IBAction func savedNameFinished(_ sender: Any) {
        if presentDataList.count == 0{return}
        savedNameConstraint.constant = 1000
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
            self.savenameBackgroundButton.alpha = 0
           
        })
        
        let savedData = SavedData(context: PersistenceService.context)
        savedData.name = savedNameText.text!
        savedData.dateSaved = presentDataList[0].date
        savedData.loanSaved = presentDataList[0].loan
        savedData.interestRateSaved = presentDataList[0].interestRate
        savedData.interestFinalSaved = presentDataList[0].interestFinal
        savedData.yearsSaved = presentDataList[0].years
        savedData.monthsSaved = presentDataList[0].months
        savedData.paymentFrequencySaved = presentDataList[0].paymentFrequency
        savedData.totalSavedFinal = presentDataList[0].totalFinal
        savedData.paymentSavedFinal = presentDataList[0].paymentFinal
        savedData.downPaymentSaved = presentDataList[0].downPayment
        
        PersistenceService.saveContext()
        self.savedDataList.append(savedData)
        
        view.endEditing(true)
        }
    
    
    
    
    //-----------------------------------Calculations------------------------------
    
    func numberOfPayments(paymentFreq: Int, years: Int, months: Int) -> Double {
        var answer = Double()
        
        if paymentFreq == 12 {
            answer = Double((years * 12) + months)
        }
        if paymentFreq == 4 {
            answer = Double((years * 4 + (months/3)))
        }
        else if paymentFreq == 1 {
            answer = Double((years + months/12))
        }
        return answer
    }
    
    func getValues(){
        var loanString: String
        var theYears = 0
        var theMonths = 0
        
        //year/date come up black for the value because it's from the picker have to use the .text
        if yearChosen.text != "" {
            theYears = Int(yearChosen.text!)!
        }
        if monthChosen.text != "" {
            theMonths = Int(monthChosen.text!)!
        }
        if  !(interestText.text?.contains("%"))! && (interestText.text?.count)! > 0{
            interestText.text?.append("%") //couldnt figure out a way to add "%" anywhere else where the keyboard would let user backspace
        }
        if loanText.text!.contains("$"){ //sometimes it bring it in with "$" and sometimes it doesnt
            loanString = String(((loanText.text!).dropFirst()))
        } else {
            loanString = loanText.text!
        }
        let interestDouble = Double((interestText.text!).dropLast())
        let extraPaymentString = ((extraPaymentText.text!).dropFirst())
        let loanDouble = Double(loanString.replacingOccurrences(of: ",", with: ""))
        let extraPaymentDouble = Double(extraPaymentString.replacingOccurrences(of: ",", with: ""))
        
        calculate(loan: loanDouble ?? 0, interest: interestDouble ?? 0, paymentFreq: paymentFrequency, years: theYears, months: theMonths, extraPayment: extraPaymentDouble ?? 0)
        
    }
    
    //if the user tries to calculate an improper calculations error pop up appears
    func findIfDivisible(){
        var theMonths = 0
        if monthChosen.text != "" {
            theMonths = Int(monthChosen.text!)!
        }
        else {
            theMonths = month
        }
        
        if paymentFrequency != 0 && theMonths != 0{
            if paymentFrequency == 4 && theMonths%3 != 0{
                errorViewConstraint.constant = 80
                UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                    self.backgroundButton.alpha = 0.5
                })
                return
            }
            
            if paymentFrequency == 1 && theMonths%12 != 0{
                errorViewConstraint.constant = 80
                UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                    self.backgroundButton.alpha = 0.5
                })
             
                return
            }
        }
      
    }
    
    
    func calculate(loan: Double, interest: Double, paymentFreq: Int, years: Int, months: Int, extraPayment: Double){
        
        if loan == 0 || interest == 0 || paymentFreq == 0 || (years == 0 && months == 0 ){
            paymentLabel.text = "$0.00"
            interestLabel.text = "$0.00"
            totalPaidLabel.text = "$0.00"
            return
        }
        
        if extraPayment > loan {
            dpErrorConstraint.constant = 80
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
                self.dpBackgroundButton.alpha = 0.5
            })
            
            return
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.currencyAccounting
        
        let totalNumberOfPayments = numberOfPayments(paymentFreq: paymentFreq, years: years, months: months)
        
        let effectiveInterestRate = (interest/100)/Double(paymentFreq)
        let denominator = pow((1 + effectiveInterestRate), -totalNumberOfPayments)
        
        var payment = (loan) * (effectiveInterestRate/(1 - denominator))
        
        var count = 0
        var principlePaid = 0.0
        var endingBalance = loan
        var interestToBePaid = 0.0
        var interestAns = 0.0
        var totalPaid = 0.0
        
        if extraPayment > 0 {
        
            while count != Int(totalNumberOfPayments){
                
                interestToBePaid = findInterest(using: endingBalance, and: effectiveInterestRate)
                
                principlePaid = findPrinciplePaid(using: payment, minus: interestToBePaid) + extraPayment
                
                endingBalance = endingBalance - (principlePaid)
                
                if interestToBePaid > 0 {
                    interestAns =  interestAns + interestToBePaid
                }
                
                count += 1
            }
            totalPaid = loan + interestAns
            payment = payment + extraPayment
            
        } else {
            totalPaid = (payment * totalNumberOfPayments)
            interestAns = totalPaid - loan
        }
        paymentLabel.text = numberFormatter.string(from: NSNumber(value: payment))
        totalPaidLabel.text = numberFormatter.string(from: NSNumber(value: totalPaid))
        interestLabel.text = numberFormatter.string(from: NSNumber(value: interestAns))
        
        saveDataForNow(totalFinal: totalPaid, paymentFinal: payment, interestFinal: interestAns, loan: loan, interestRate: interest, years: years, months: months, paymentFrequency: paymentFreq, extraPayment: extraPayment)
        
    }
    
    func findInterest(using balanceOwed: Double, and interestRate: Double) -> Double {
        return balanceOwed * interestRate
    }
    
    func findPrinciplePaid(using payment: Double, minus interestPaid: Double) -> Double{
        return payment - interestPaid
    }
    
    @objc func donePressed() {
        getPayFrequency()
        getValues() // everytime user updates values the answers change
        findIfDivisible()
        view.endEditing(true)
    }
    
    func getPayFrequency(){
        if monthlyButton.backgroundColor == #colorLiteral(red: 0.2196078431, green: 0.9764705882, blue: 0.9450980392, alpha: 1) {
            paymentFrequency = 12
        }
        if quarterlyButton.backgroundColor == #colorLiteral(red: 0.2196078431, green: 0.9764705882, blue: 0.9450980392, alpha: 1) {
            paymentFrequency = 4
        }
        if yearlyButton.backgroundColor == #colorLiteral(red: 0.2196078431, green: 0.9764705882, blue: 0.9450980392, alpha: 1) {
            paymentFrequency = 1
        }
    }
    
    @objc func interestRateTextFieldChange(_ textField: UITextField){
        if let amountString = textField.text?.percentageFormatting() {
            textField.text = amountString
        }
    }
    
    @objc func loanTextFieldChange(_ textField: UITextField) {
        
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
    }
    
    func dontSave() -> Bool {
        if  paymentLabel.text == "$0.00" &&
            interestLabel.text == "$0.00" &&
            totalPaidLabel.text == "$0.00" {
            return true
        }
        return false
    }
    
    
    @IBAction func saveDatePressed(_ sender: Any) {
       
        if presentDataList.count == 0 || dontSave(){
            errorViewConstraint.constant = 80
            errorLabel.text = "Unable to save! Your loan information is not complete."
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
                self.backgroundButton.alpha = 0.5
            })
            return
        }
        
        presentDataList.removeAll()
        
        getValues()
        
        nameSavePopUp()
        
        if savedNameText == nil {
            savedNameText.text = "?"
        }
        
    }
    
    func nameSavePopUp(){
        savedNameConstraint.constant = 20
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.savenameBackgroundButton.alpha = 0.5
        })
    }
}

extension String {
    // formatting text for currency textField
    func currencyInputFormatting() -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double) / 100)
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        
        return formatter.string(from: number)!
    }
    
    func percentageFormatting() -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 3
        formatter.minimumFractionDigits = 3
        
        var amountWithPrefix = self
        
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double)/1000)
        guard number != 0 as NSNumber else {
            return ""
        }
        return (formatter.string(from: number)!)
    }
}
