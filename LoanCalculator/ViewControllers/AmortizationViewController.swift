
import UIKit
import CoreData
import StoreKit

class Payment {
    var paymentNumber = String()
    var interestPaid = String()
    var principlePaid = String()
    var endingBalance = String()
    var date = String()
    
    init (paymentNumber: String, interestPaid: String, principlePaid: String, endingBalance: String, date: String){
        self.paymentNumber = paymentNumber
        self.interestPaid = interestPaid
        self.principlePaid = principlePaid
        self.endingBalance = endingBalance
        self.date = date
    }
}


class AmortizationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var presentDataList = [UserData]()
    var paymentList = [Payment]()
    var dates = Date()
    var endingBalance = Double()
    var paymentFrequency = Int16()
    var loan = Double()
    var interestRate = Double()
    var payment = Double()
    var numberOfPayments = Int()
    var years = Int16()
    var months = Int16()
    var dateArray = [Date]()
    var downPayment = Double()
    var payFinal = Double()
    var countString = ""
    var counter = [TimesOpened]()
    var numberOfTimesOpened = 0
    
    
    @IBOutlet weak var timeSavedLabel: UILabel!
    @IBOutlet weak var moneySavedLabel: UILabel!
    
    @IBOutlet weak var payOffDay: UILabel!
    var interestToBePaid = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequestForCount: NSFetchRequest<TimesOpened> = TimesOpened.fetchRequest()
        do{
            let count = try PersistenceService.context.fetch(fetchRequestForCount)
            counter = count
        } catch {}
        
        let fetchRequest: NSFetchRequest<UserData> = UserData.fetchRequest()
        
        do {
            let dataList = try PersistenceService.context.fetch(fetchRequest)
            presentDataList = dataList
            
        } catch {}
        
        retreiveValues()
        findValues()
        findAmountSaved()
        incrementCounter()
        
    }
    
    func incrementCounter(){
        let countedNumber = TimesOpened(context: PersistenceService.context)
        if counter.count == 0 {
            counter.append(countedNumber)
            counter[0].count = 1
            countedNumber.count = counter[0].count
        } else {
            counter[0].count += 1
            countedNumber.count = counter[0].count
        }
        PersistenceService.saveContext()
        if counter[0].count == 3 || counter[0].count == 10 || counter[0].count % 30 == 0 {
            requestReview()
        }
    }
    
    func requestReview(){
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            return
        }
    }
    
    func retreiveValues(){
        if presentDataList.count > 0{
            paymentFrequency = presentDataList[0].paymentFrequency
            loan = presentDataList[0].loan
            interestRate = presentDataList[0].interestRate
            payment = presentDataList[0].paymentFinal
            numberOfPayments = findNumberOfPayments()
            years = presentDataList[0].years
            months = presentDataList[0].months
            dates = presentDataList[0].date
            downPayment = presentDataList[0].downPayment
            payFinal = presentDataList[0].totalFinal
        }
        else {
            return
        }
    }
    
    func findNumberOfPayments() -> Int{
        var answer = Int()
        
        let totalMonths = (years * 12) + months
        
        if paymentFrequency == 12 {
            answer = Int(totalMonths)
        }
        if paymentFrequency == 4{
            answer = Int(totalMonths)/3
        }
        else if paymentFrequency == 1 {
            answer = Int(years) + Int(months/12)
        }
        createDateArray(using: answer)
        return answer
    }
    
    func createDateArray(using numberOfPayments: Int){
        var count = 0
        
        var theDate = dates
        
        if paymentFrequency == 4 {
            while count != numberOfPayments {
                dateArray.append(theDate)
                theDate = Calendar.current.date(byAdding: .month, value: 3, to: theDate)!
                count += 1
            }
        }
        if paymentFrequency == 12 {
            while count != numberOfPayments {
                dateArray.append(theDate)
                theDate = Calendar.current.date(byAdding: .month, value: 1, to: theDate)!
                count += 1
            }
        }
        if paymentFrequency == 1 {
            while count != numberOfPayments {
                dateArray.append(theDate)
                theDate = Calendar.current.date(byAdding: .year, value: 1, to: theDate)!
                count += 1
            }
        }
    }
    
    func updatePayOffDate(){
        payOffDay.text = paymentList[paymentList.count - 1].date
    }
    
    func findAmountSaved(){
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.currencyAccounting
        
        if downPayment > 0 {
            let effectiveInterestRate = (interestRate/100)/Double(paymentFrequency)
            let denominator = pow((1 + effectiveInterestRate), Double(-numberOfPayments))
            let payment = (loan) * (effectiveInterestRate/(1 - denominator))
            let totalPaid = (payment * Double(numberOfPayments))
            moneySavedLabel.text = numberFormatter.string(from: NSNumber(value: totalPaid - payFinal))
            timeSavedLabel.text = findTimeSaved()
        }
    }
    
    func findTimeSaved() -> String{
        var answer = 0
        
        if paymentFrequency == 12 {
            answer = (numberOfPayments - Int(countString)!)
        }
        if paymentFrequency == 4 {
            answer = ((numberOfPayments - Int(countString)!) * 3)
        }
        else if paymentFrequency == 1{
            answer = ((numberOfPayments - Int(countString)!) * 12)
        }
        
        return turnToString(answer: answer)
    }
    
    func turnToString(answer: Int)-> String {
        var years = 0
        var months = 0
        if answer > 12 {
            years = answer / 12
            months = answer - years * 12
            
            return "\(years) Years \(months) Months"
        }
        else {
            return "\(answer) months"
        }
    }
    
    
    
    func findValues(){
        if presentDataList.count > 0 {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.currencyAccounting
            numberOfPayments = findNumberOfPayments()
            endingBalance = loan
            
            var principlePaid = 0.0
            var count = 0
            let rate = (interestRate/100)/Double(paymentFrequency)
            while endingBalance != 0 && paymentList.count != dateArray.count{
                interestToBePaid = findInterest(using: endingBalance, and: rate)
                principlePaid = findPrinciplePaid(using: payment, minus: interestToBePaid)
                endingBalance = endingBalance - principlePaid
                
                if endingBalance < 0{
                    principlePaid = principlePaid + endingBalance
                    endingBalance = 0
                }
                
                let endingBalanceString = numberFormatter.string(from: NSNumber(value: endingBalance))
                let interestToBePaidString = numberFormatter.string(from: NSNumber(value: interestToBePaid))
                let principlePaidString = numberFormatter.string(from: NSNumber(value:principlePaid))
                countString = String(count + 1)
                
                let dateString = getDate(date: dateArray[count])
                
                paymentList.append(Payment(paymentNumber: countString, interestPaid: interestToBePaidString!, principlePaid: principlePaidString!, endingBalance: endingBalanceString!, date: dateString))
                count += 1
            }
            updatePayOffDate()
        }
    }
    
    func getDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func findInterest(using balanceOwed: Double, and interestRate: Double) -> Double {
        return balanceOwed * interestRate
    }
    
    func findPrinciplePaid(using payment: Double, minus interestPaid: Double) -> Double{
        return payment - interestPaid
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AmortizationTableViewCell
        
        if (indexPath.row % 2 == 0)
        {
            cell.backgroundColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        } else {
            cell.backgroundColor = #colorLiteral(red: 0.1864618063, green: 0.1864618063, blue: 0.1864618063, alpha: 1)
        }
        cell.number.text = paymentList[indexPath.row].paymentNumber
        cell.interest.text = paymentList[indexPath.row].interestPaid
        cell.principle.text = paymentList[indexPath.row].principlePaid
        cell.balance.text = paymentList[indexPath.row].endingBalance
        cell.date.text = paymentList[indexPath.row].date
        return (cell)
    }
    
}


















