
import UIKit
import Charts
import CoreData

class GraphViewController: UIViewController {
    
    @IBOutlet weak var pieChart: PieChartView!
    
    @IBOutlet weak var lineChart: LineChartView!
    
    @IBOutlet weak var graphLabel: UILabel!
    var interestDataEntry = Double()
    var principleDataEntry = Double()
    var pieValues = [Double]()
    
    let lineChartView = LineChartView()
    var interestLineDataEntry: [ChartDataEntry] = []
    var balanceLineDataEntry: [ChartDataEntry] = []
    var totalLineDataEntry: [ChartDataEntry] = []
    var principleLineDataEntry: [ChartDataEntry] = []
    var presentDataList = [UserData]()
    var endingBalance = Double()
    var paymentFrequency = Int16()
    var loan = Double()
    var extraPayment = Double()
    var interestRate = Double()
    var payment = Double()
    var numberOfPayments = Int()
    var years = Int16()
    var months = Int16()
    var interestToBePaid = 0.0
    var interestPercent = Double()
    var char = ""
    var str = ""
    
    let piechartLabel = ["Interest", "Loan Amount"]
    
    var interestArray = [Double]()
    var balanceOwed = [Double]()
    var principle = [Double]()
    var totalPaid = [Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest: NSFetchRequest<UserData> = UserData.fetchRequest()
        
        do {
            let dataList = try PersistenceService.context.fetch(fetchRequest)
            presentDataList = dataList
            
        } catch {}
        
        graphLabel.text = ""
        lineChart.noDataText = ""
        retreiveValues()
        findValues()
        pieChartViewSetUp()
        pieValues = [interestDataEntry, principleDataEntry]
        updatePieChartData(datePoints: piechartLabel, values: pieValues)
        
        let stringInterestPercent =  "\(String(format: "%.2f", interestPercent * 100))"
        messageArray.insert(stringInterestPercent, at: 0)
        
        startDisplayLink()
        
        
    }
    
    var counter = 0
    var startValue: Double = 0
    let endValue: Double = 1000
    var animationDuration: Double = 0.01
    var animationStartDate = Date()
    var messageArray = ["%", " ", "o", "f", " ","t", "h","e"," ", "t","o","t", "a", "l",
                        " ","p","a", "i","d"," ", "i", "s", " ", "i","n"," ", "i","n","t", "e", "r","e","s","t."]
    var noDataArray = ["N", "o", " ", "i", "n","f", "o", "r", "m","a", "t","i", "o","n"," ","e", "n","t","e", "r", "e",
                       "d!"]
    
    private var displayLink: CADisplayLink?
    
    func startDisplayLink(){
        let displayLink = CADisplayLink(target: self, selector: #selector(handleUpdate))
        displayLink.add(to: .main, forMode: .defaultRunLoopMode)
        self.displayLink = displayLink
    }
    
    @objc func handleUpdate(){
        var messageToUser = [String]()
        if presentDataList.count == 0 {
            messageToUser = noDataArray
        }else{
            messageToUser = messageArray
        }
        let now = Date()
        var elapsedTime = now.timeIntervalSince(animationStartDate)
        
        if elapsedTime > animationDuration && counter < messageToUser.count {
            
            if counter < messageToUser.count {
                char = messageToUser[counter]
                animationDuration += 0.05
                str += char
            }
            graphLabel.text = str
            counter += 1
        }
        if  counter >= messageToUser.count {
            stopDisplayLink()
            elapsedTime = animationDuration
        }
    }
    func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    
    func retreiveValues(){
        if presentDataList.count > 0{
            paymentFrequency = presentDataList[0].paymentFrequency
            loan = presentDataList[0].loan
            extraPayment = presentDataList[0].downPayment
            interestRate = presentDataList[0].interestRate
            payment = presentDataList[0].paymentFinal
            numberOfPayments = findNumberOfPayments()
            years = presentDataList[0].years
            months = presentDataList[0].months
            interestDataEntry = presentDataList[0].interestFinal
            principleDataEntry = presentDataList[0].loan
            interestPercent = (presentDataList[0].interestFinal/presentDataList[0].totalFinal)
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
        else if paymentFrequency == 4{
            answer = Int(totalMonths)/4
        }
        else {
            answer = Int(years)
        }
        return answer
    }
    
    func findValues(){
        if presentDataList.count > 0 {
            numberOfPayments = findNumberOfPayments()
            endingBalance = loan
            var loanPrinciple = loan
            var principlePaid = 0.0
            var count = 0
            var total = 0.0
            var totalInterestPaid = 0.0
            var principleOwned = 0.0
            let rate = (interestRate/100)/Double(paymentFrequency)
            while endingBalance != 0 {// && paymentList.count != dateArray.count{
                interestToBePaid = findInterest(using: endingBalance, and: rate)
                principlePaid = findPrinciplePaid(using: payment, minus: interestToBePaid)
                endingBalance = endingBalance - principlePaid
                
                if endingBalance < 0{
                    principlePaid = principlePaid + endingBalance
                    endingBalance = 0
                }
    
                totalPaid.append(total)
                interestArray.append(totalInterestPaid)
                principle.append(principleOwned)
                balanceOwed.append(loanPrinciple)
                principleOwned += principlePaid
                totalInterestPaid += interestToBePaid
                loanPrinciple -= principlePaid
                total = principleOwned + totalInterestPaid
                count += 1
            }
            updateLineChartData(interest: interestArray, balance: balanceOwed, principle: principle, total: totalPaid)
        }
        
    }
    
    func findInterest(using balanceOwed: Double, and interestRate: Double) -> Double {
        return balanceOwed * interestRate
    }
    
    func findPrinciplePaid(using payment: Double, minus interestPaid: Double) -> Double{
        return payment - interestPaid
    }
    
    func updateLineChartData(interest: [Double], balance: [Double], principle: [Double], total: [Double]){
        
        lineChart.configureDefaults()
        
        for i in 0..<interest.count {
            let interestPoints = ChartDataEntry(x: Double(i), y: interest[i])
            interestLineDataEntry.append(interestPoints)
        }
        for i in 0..<balance.count {
            let balancePoints = ChartDataEntry(x: Double(i), y: balance[i])
            balanceLineDataEntry.append(balancePoints)
        }
        for i in 0..<principle.count {
            let principlePoints = ChartDataEntry(x: Double(i), y: principle[i])
            principleLineDataEntry.append(principlePoints)
        }
        for i in 0..<totalPaid.count {
            let totalPoints = ChartDataEntry(x: Double(i), y: total[i])
            totalLineDataEntry.append(totalPoints)
        }
        let colorLocations: [CGFloat] = [1.0, 0.0]
        
        let interestChartDataSet = LineChartDataSet(values: interestLineDataEntry, label: "Interest")
        let balanceChartDataSet = LineChartDataSet(values: balanceLineDataEntry, label: "Balance")
        let principleChartDataSet = LineChartDataSet(values: principleLineDataEntry, label: "Principal")
        let totalChartDataSet = LineChartDataSet(values: totalLineDataEntry, label: "Total Paid")
        
        interestChartDataSet.colors = [UIColor(cgColor: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1))]
        
        interestChartDataSet.drawCirclesEnabled = false
        let interestGradientColors = [#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), UIColor.clear.cgColor] as CFArray
        guard let interestGradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: interestGradientColors, locations: colorLocations) else { print("gradient error"); return}
        interestChartDataSet.fill = Fill.fillWithLinearGradient(interestGradient, angle: 90.0)
        interestChartDataSet.drawFilledEnabled = true
        
        balanceChartDataSet.colors = [UIColor(cgColor: #colorLiteral(red: 0.2196078431, green: 0.9764705882, blue: 0.568627451, alpha: 1))]
        balanceChartDataSet.drawCirclesEnabled = false
        let balanceGradientColors = [#colorLiteral(red: 0.2196078431, green: 0.9764705882, blue: 0.568627451, alpha: 1), UIColor.clear.cgColor] as CFArray
        guard let balanceGradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: balanceGradientColors, locations: colorLocations) else { print("gradient error"); return}
        balanceChartDataSet.fill = Fill.fillWithLinearGradient(balanceGradient, angle: 90.0)
        balanceChartDataSet.drawFilledEnabled = true
        
        principleChartDataSet.colors = [UIColor(cgColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))]
        principleChartDataSet.drawCirclesEnabled = false
        let principleGradientColors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), UIColor.clear.cgColor] as CFArray
        guard let principleGradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: principleGradientColors, locations: colorLocations) else { print("gradient error"); return}
        principleChartDataSet.fill = Fill.fillWithLinearGradient(principleGradient, angle: 90.0)
        principleChartDataSet.drawFilledEnabled = true
        
        totalChartDataSet.colors = [UIColor(cgColor: #colorLiteral(red: 0.2196078431, green: 0.9764705882, blue: 0.9450980392, alpha: 1))]
        totalChartDataSet.drawCirclesEnabled = false
        let totalGradientColors = [#colorLiteral(red: 0.2196078431, green: 0.9764705882, blue: 0.9450980392, alpha: 1),UIColor.clear.cgColor]  as CFArray
        guard let totalGradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: totalGradientColors, locations: colorLocations) else { print("gradient error"); return}
        totalChartDataSet.fill = Fill.fillWithLinearGradient(totalGradient, angle: 90.0)
        totalChartDataSet.drawFilledEnabled = true
        
        let chartData = LineChartData()
        
        chartData.addDataSet(interestChartDataSet)
        chartData.addDataSet(balanceChartDataSet)
        chartData.addDataSet(principleChartDataSet)
        chartData.addDataSet(totalChartDataSet)
        chartData.setDrawValues(false)
        
        lineChart.data = chartData
    }
    
    
    func pieChartViewSetUp(){
        pieChart.chartDescription?.text = ""
        pieChart.usePercentValuesEnabled = true
        pieChart.holeRadiusPercent = 0.8
        pieChart.holeColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        pieChart.isUserInteractionEnabled = false
        pieChart.legend.formSize = 15
        pieChart.legend.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        pieChart.drawEntryLabelsEnabled = false
        pieChart.legend.font = UIFont(name: "HelveticaNeue-medium", size: 13)!
        pieChart.noDataText = ""
        
    }
    
    func updatePieChartData(datePoints: [String], values: [Double]){
        var dataEntries: [PieChartDataEntry] = []
        if presentDataList.count != 0 {
            for i in 0..<datePoints.count {
                let dataEntry = PieChartDataEntry(value: Double(values[i]), label: datePoints[i])
                dataEntries.append(dataEntry)
            }
            
            let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "")
            
            let colors = [UIColor(cgColor: #colorLiteral(red: 0.2196078431, green: 0.9764705882, blue: 0.9450980392, alpha: 1)), UIColor(cgColor: #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1))]
            
            pieChartDataSet.colors = colors
            pieChartDataSet.drawValuesEnabled = false
            
            pieChart.animate(xAxisDuration: 0.7)
            pieChart.animate(yAxisDuration: 0.7)
            
            let pieChartData = PieChartData(dataSet: pieChartDataSet)
            
            pieChart.data = pieChartData
        }
    }
}

private extension BarLineChartViewBase {
    func configureDefaults() {
       
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        
        chartDescription?.text = ""
        animate(xAxisDuration: 1.5)
        xAxis.labelPosition = .bottom
        rightAxis.enabled = false
        xAxis.drawGridLinesEnabled = false
        leftAxis.drawGridLinesEnabled = false
        legend.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        xAxis.labelTextColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        legend.formSize = 15
        legend.font = UIFont(name: "HelveticaNeue-light", size: 13)!
        leftAxis.labelTextColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
}
















