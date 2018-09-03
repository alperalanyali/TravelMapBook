//
//  MainVC.swift
//  Travel Map Book
//
//  Created by Alper on 2.09.2018.
//  Copyright © 2018 Alper. All rights reserved.
//

import UIKit
import CoreData


class MainVC: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var titleArray = [String]()
    var subtitleArray = [String]()
    var latitudeArray = [Double]()
    var longitudeArray = [Double]()
    
    var chosenTitle = ""
    var chosenSubtitle = ""
    var chosenLatitude: Double = 0
    var chosenLongitude: Double = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchData), name: NSNotification.Name(rawValue: "newLocationCreated"), object: nil)
    }
    
   @objc func fetchData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Locations")
        request.returnsObjectsAsFaults = false
        do{
            
            self.titleArray.removeAll(keepingCapacity: false)
            self.subtitleArray.removeAll(keepingCapacity: false)
            self.latitudeArray.removeAll(keepingCapacity: false)
            self.longitudeArray.removeAll(keepingCapacity: false)
            
            
            
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let title = result.value(forKey: "title") as? String {
                        self.titleArray.append(title)
                    }
                    
                    if let subtitle = result.value(forKey: "subtitle") as? String {
                        self.subtitleArray.append(subtitle)
                    }
                    
                    if let lattitude = result.value(forKey: "latitude") as? Double {
                        self.latitudeArray.append(lattitude)
                    }
                    
                    if let longitude = result.value(forKey: "longitude") as? Double {
                        self.longitudeArray.append(longitude)
                    }
                    
                    self.tableView.reloadData()
                }
            }
            
            
            
        } catch {
            print("Error in fetching data from Coredata for TableView")
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, nil) in
            self.titleArray.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .left)
            tableView.endUpdates()

        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenTitle = titleArray[indexPath.row]
        chosenSubtitle = subtitleArray[indexPath.row]
        chosenLatitude = latitudeArray[indexPath.row]
        chosenLongitude = longitudeArray[indexPath.row]
        performSegue(withIdentifier: "toMapVC", sender: nil)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapVC" {
            let destinationVC = segue.destination as! MapVC
            destinationVC.transmittedTitle = chosenTitle
            destinationVC.transmittedSubtitle = chosenSubtitle
            destinationVC.transmittedLatitude = chosenLatitude
            destinationVC.transmittedLongitude = chosenLongitude
        }
    }
    
    
    @IBAction func addButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "toMapVC", sender: nil)
        
    }
}
