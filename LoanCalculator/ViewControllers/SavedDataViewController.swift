
import UIKit
import CoreData

class SavedDataViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var savedDataList = [SavedData]()
    var presentDataList = [UserData]()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest: NSFetchRequest<SavedData> = SavedData.fetchRequest()
        do {
            let savedList = try PersistenceService.context.fetch(fetchRequest)
            savedDataList = savedList.reversed()
        } catch {}
        let fetchRequestForPresentdata: NSFetchRequest<UserData> = UserData.fetchRequest()
        do {
            let presentList = try PersistenceService.context.fetch(fetchRequestForPresentdata)
            presentDataList = presentList
        } catch{}
    }
    
    func reload(){
        tableView.reloadData()
    }
    
    func convertDate(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func convertPayFreq(frequency: Int16) -> String{
        var answer = String()
        
        if frequency == 1 {
            answer = "Yearly"
        }
        if frequency == 4 {
            answer = "Quarterly"
        }
        if frequency == 12 {
            answer = "Monthly"
        }
        return answer
    }
    
    func getLoanDuration(using months: Int16, and years: Int16) -> String{
        var newYears = years
        var newMonths = months
        var numOfYears = Int16()
        if months > 12 {
            numOfYears = newMonths/12
            newYears += numOfYears
            newMonths = newMonths - numOfYears*12
            return "\(newYears) Years \(newMonths) Months"
        } else {
            return "\(newYears) Years \(newMonths) Months"
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.currencyAccounting
        let saveCell = tableView.dequeueReusableCell(withIdentifier: "saveCell", for: indexPath) as! SavedDataTableViewCell
        if (indexPath.row % 2 == 0)
        {
            saveCell.cellBackground.backgroundColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        } else {
            saveCell.cellBackground.backgroundColor = #colorLiteral(red: 0.1864618063, green: 0.1864618063, blue: 0.1864618063, alpha: 1)
        }
        saveCell.name.text = savedDataList[indexPath.row].name
        
        saveCell.date.text = "\(convertDate(date: savedDataList[indexPath.row].dateSaved))"
        
        saveCell.loan.text = numberFormatter.string(from: NSNumber(value: savedDataList[indexPath.row].loanSaved))
        
        saveCell.interest.text = "\(savedDataList[indexPath.row].interestRateSaved)%"
        
        saveCell.paymentFrequency.text = convertPayFreq(frequency: savedDataList[indexPath.row].paymentFrequencySaved)
        
        saveCell.loanDuration.text = getLoanDuration(using: savedDataList[indexPath.row].monthsSaved, and: savedDataList[indexPath.row].yearsSaved)
        
        saveCell.additionalPayment.text = numberFormatter.string(from: NSNumber(value: savedDataList[indexPath.row].downPaymentSaved))
        
        return saveCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete
        {
            let savedData = savedDataList[indexPath.row]
            PersistenceService.context.delete(savedData)
            PersistenceService.saveContext()
            savedDataList.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         print(presentDataList.count)
        if presentDataList.count > 0 {
         presentDataList[0].date = savedDataList[indexPath.row].dateSaved
         presentDataList[0].loan = savedDataList[indexPath.row].loanSaved
         presentDataList[0].interestRate = savedDataList[indexPath.row].interestRateSaved
         presentDataList[0].interestFinal = savedDataList[indexPath.row].interestFinalSaved
         presentDataList[0].downPayment = savedDataList[indexPath.row].downPaymentSaved
         presentDataList[0].months = savedDataList[indexPath.row].monthsSaved
         presentDataList[0].years = savedDataList[indexPath.row].yearsSaved
         presentDataList[0].paymentFrequency = savedDataList[indexPath.row].paymentFrequencySaved
         presentDataList[0].totalFinal = savedDataList[indexPath.row].totalSavedFinal
         presentDataList[0].paymentFinal = savedDataList[indexPath.row].paymentSavedFinal
         PersistenceService.saveContext()
        }else if presentDataList.count == 0{
         let userData = UserData(context: PersistenceService.context)
        userData.date = savedDataList[indexPath.row].dateSaved
        userData.totalFinal = savedDataList[indexPath.row].totalSavedFinal
        userData.paymentFinal = savedDataList[indexPath.row].paymentSavedFinal
        userData.interestFinal = savedDataList[indexPath.row].interestFinalSaved
        userData.loan = savedDataList[indexPath.row].loanSaved
        userData.interestRate = savedDataList[indexPath.row].interestRateSaved
        userData.years = savedDataList[indexPath.row].yearsSaved
        userData.months = savedDataList[indexPath.row].monthsSaved
        userData.downPayment = savedDataList[indexPath.row].downPaymentSaved
        userData.paymentFrequency = savedDataList[indexPath.row].paymentFrequencySaved
        presentDataList.append(userData)
        }
         performSegue(withIdentifier: "segua", sender: self)
    }
    
    @IBAction func editRows(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
    }
    
    @IBAction func trash(_ sender: Any) {
        let alert = UIAlertController(title: "Delete All?", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in alert.dismiss(animated: true, completion: nil)
            do {
                try PersistenceService.context.execute(NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "SavedData")))
                PersistenceService.saveContext()
                
            } catch{}
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func deletePresentData(){
        do {
            try PersistenceService.context.execute(NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "UserData")))
            PersistenceService.saveContext()
        } catch{}
    }
}
