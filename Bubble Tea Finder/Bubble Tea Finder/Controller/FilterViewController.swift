/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import CoreData

protocol FilterViewControllerDelegate: class {
  func filterViewController(filter: FilterViewController,
                            didSelectPredicate predicate: NSPredicate?,
                            sortDescriptor: NSSortDescriptor?)
}

class FilterViewController: UITableViewController {

  // MARK: Properties
  
  var coreDataStack: CoreDataStack!
  lazy var cheapVenuePredicate: NSPredicate = {
    return NSPredicate(format: "%K == %@", #keyPath(Venue.priceInfo.priceCategory), "$")
  }()
  lazy var moderateVenuePredicate: NSPredicate = {
    return NSPredicate(format: "%K == %@",
                       #keyPath(Venue.priceInfo.priceCategory), "$$")
  }()
  lazy var expensiveVenuePredicate: NSPredicate = {
    return NSPredicate(format: "%K == %@",
                       #keyPath(Venue.priceInfo.priceCategory), "$$$")
  }()
  
  weak var delegate: FilterViewControllerDelegate?
  var selectedSortDescriptor: NSSortDescriptor?
  var selectedPredicate: NSPredicate?
  
  lazy var offeringDealPredicate: NSPredicate = {
    return NSPredicate(format: "%K > 0",
                       #keyPath(Venue.specialCount))
  }()
  lazy var walkingDistancePredicate: NSPredicate = {
    return NSPredicate(format: "%K < 500",
                       #keyPath(Venue.location.distance))
  }()
  lazy var hasUserTipsPredicate: NSPredicate = {
    return NSPredicate(format: "%K > 0",
                       #keyPath(Venue.stats.tipCount))
  }()
  
  // MARK: IB Outlets
  
  @IBOutlet weak var firstPriceCategoryLabel: UILabel!
  @IBOutlet weak var secondPriceCategoryLabel: UILabel!
  @IBOutlet weak var thirdPriceCategoryLabel: UILabel!
  @IBOutlet weak var numDealsLabel: UILabel!

  // Price Section
  @IBOutlet weak var cheapVenueCell: UITableViewCell!
  @IBOutlet weak var moderateVenueCell: UITableViewCell!
  @IBOutlet weak var expensiveVenueCell: UITableViewCell!

  // Most Popular Section
  @IBOutlet weak var offeringDealCell: UITableViewCell!
  @IBOutlet weak var walkingDistanceCell: UITableViewCell!
  @IBOutlet weak var userTipsCell: UITableViewCell!
  
  // Sort Section
  @IBOutlet weak var nameAZSortCell: UITableViewCell!
  @IBOutlet weak var nameZASortCell: UITableViewCell!
  @IBOutlet weak var distanceSortCell: UITableViewCell!
  @IBOutlet weak var priceSortCell: UITableViewCell!

  // MARK: View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    populateVenueCountLabel(predicate: cheapVenuePredicate, label: firstPriceCategoryLabel)
    populateVenueCountLabel(predicate: moderateVenuePredicate, label: secondPriceCategoryLabel)
    populateVenueCountLabel(predicate: expensiveVenuePredicate, label: thirdPriceCategoryLabel)
    
    populateDealsCountLabel()
  }
  
  // MARK: Helper Methods
  
  func populateVenueCountLabel(predicate: NSPredicate, label: UILabel) {
    let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Venue")
    fetchRequest.resultType = .countResultType
    fetchRequest.predicate = predicate
    
    do {
      let countResult = try coreDataStack.managedContext.fetch(fetchRequest)
      let count = countResult.first!.intValue
      label.text = "\(count) bubble tea places"
    } catch let error as NSError {
      print("Count not fetch \(error), \(error.userInfo)")
    }
    
     /* Alternative solution to this method:
     let fetchRequest: NSFetchRequest<Venue> = Venue.fetchRequest()
     fetchRequest.predicate = expensiveVenuePredicate
     do {
      let count = try coreDataStack.managedContext.count(for: fetchRequest)
      thirdPriceCategoryLabel.text = "\(count) bubble tea places"
     } catch let error as NSError {
      print("Count not fetch \(error), \(error.userInfo)")
     }
     */
  }
  
  func populateDealsCountLabel() {
    let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Venue")
    fetchRequest.resultType = .dictionaryResultType
    
    let sumExpressionDescription = NSExpressionDescription()
    sumExpressionDescription.name = "sumDeals"
    
    let specialCountExpression = NSExpression(forKeyPath: #keyPath(Venue.specialCount))
    sumExpressionDescription.expression = NSExpression(forFunction: "sum:", arguments: [specialCountExpression])
    
    sumExpressionDescription.expressionResultType = .integer32AttributeType
    
    fetchRequest.propertiesToFetch = [sumExpressionDescription]
    
    do {
      let results = try coreDataStack.managedContext.fetch(fetchRequest)
      let resultDict = results.first!
      let numDeals = resultDict["sumDeals"]!
      numDealsLabel.text = "\(numDeals) total deals"
    } catch let error as NSError {
      print("Count not fetch \(error), \(error.userInfo)")
    }
  }
  
  // MARK: IB Actions
  
  @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
    delegate?.filterViewController(filter: self,
                                   didSelectPredicate: selectedPredicate,
                                   sortDescriptor: selectedSortDescriptor)
    dismiss(animated: true)
  }
  
}

// MARK: UITableView Delegate
extension FilterViewController {

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    
    switch cell {
      // Price Section
      case cheapVenueCell:
        selectedPredicate = cheapVenuePredicate
      case moderateVenueCell:
        selectedPredicate = moderateVenuePredicate
      case expensiveVenueCell:
        selectedPredicate = expensiveVenuePredicate
      
      // Most Popular Section
      case offeringDealCell:
        selectedPredicate = offeringDealPredicate
      case walkingDistanceCell:
        selectedPredicate = walkingDistancePredicate
      case userTipsCell:
        selectedPredicate = hasUserTipsPredicate
      default:
        break
    }
    
    cell.accessoryType = .checkmark
  }
}
