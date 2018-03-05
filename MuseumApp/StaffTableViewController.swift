//
//  StaffTableViewController.swift
//  MuseumApp
//
//  Created by Orsolya Lukacs-Kisbandi on 26/02/2018.
//  Copyright © 2018 Orsolya Lukacs-Kisbandi. All rights reserved.
//

import UIKit
import os.log

class StaffTableViewController: UITableViewController {
    
    var paintings = [Painting]()
    
    
    //MARK: Private Methods
    
    private func loadSampleMeals() {
        let photo1 = UIImage(named: "Painting_impression")
        let photo2 = UIImage(named: "Painting_park")
        let photo3 = UIImage(named: "Painting_poppies")
        
        guard let meal1 = Painting(name: "Impression", photo: photo1) else {
            fatalError("Unable to instantiate impression")
        }
        
        guard let meal2 = Painting(name: "Park", photo: photo2) else {
            fatalError("Unable to instantiate park")
        }
        
        guard let meal3 = Painting(name: "Poppies", photo: photo3) else {
            fatalError("Unable to instantiate poppies")
        }
        
        paintings += [meal1, meal2, meal3]
    }
    
    // To display dynamic data, a table view needs two important helpers: a data source and a delegate. A table view data source, as implied by its name, supplies the table view with the data it needs to display. A table view delegate helps the table view manage cell selection, row heights, and other aspects related to displaying the data.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        loadSampleMeals()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paintings.count
    }
    
    // For any given row in the table view, you configure the cell by fetching the corresponding Painting in the paintings array, and then setting the cell’s properties to corresponding values from the Painting class.
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "StaffTableViewCell"
        
        // Because you created a custom cell class that you want to use, downcast the type of the cell to your custom cell subclass, StaffTableViewCell.
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? StaffTableViewCell  else {
            fatalError("The dequeued cell is not an instance of StaffTableViewCell.")
        }
        // The dequeueReusableCell(withIdentifier:for:) method requests a cell from the table view. Instead of creating new cells and deleting old cells as the user scrolls, the table tries to reuse the cells when possible.
        // The as? StaffTableViewCell expression attempts to downcast the returned object from the UITableViewCell class to your StaffTableViewCell class. This returns an optional.
        
        // The guard let expression safely unwraps the optional.
        
        // If your storyboard is set up correctly, and the cellIdentifier matches the identifier from your storyboard, then the downcast should never fail. If the downcast does fail, the fatalError() function prints an error message to the console and terminates the app.
        
        // Fetches the appropriate painting for the data source layout.
        let painting = paintings[indexPath.row]
        cell.nameLabel.text = painting.name
        cell.photoImageView.image = painting.photo
//        cell.ratingControl.rating = painting.rating
        
        
        return cell
    }
    
    // MARK: Actions
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? StaffViewController, let painting = sourceViewController.painting {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing painting.
                paintings[selectedIndexPath.row] = painting
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new painting.
                let newIndexPath = IndexPath(row: paintings.count, section: 0)
                
                paintings.append(painting)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            paintings.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new painting.", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let mealDetailViewController = segue.destination as? StaffViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedMealCell = sender as? StaffTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedMeal = paintings[indexPath.row]
            mealDetailViewController.painting = selectedMeal
        case "HomeScreen":
            os_log("Homebutton pressed", log: OSLog.default, type: .debug)
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    
}
