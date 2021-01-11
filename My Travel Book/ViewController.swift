//
//  ViewController.swift
//  My Travel Book
//
//  Created by Serhat Küçük on 7.01.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var tableView: UITableView!
    
    var savedPlaceName = ""
    var savedPlaceId = UUID()
    var placeNameArray = [String]()
    var placeIdArray = [UUID]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        getData()
        
        
    }

    override func viewWillAppear(_ animated: Bool) {


        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("NewPlaceSaved"), object: nil)
        
    }

    @objc func deleteOriginalItem(placeId : UUID){
        
        
    }
    
    
    @objc func getData(){
        
        placeNameArray.removeAll(keepingCapacity: false)
        placeIdArray.removeAll(keepingCapacity: false)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            
            let results = try context.fetch(fetchRequest)
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "name") as? String{
                        placeNameArray.append(name)
                        
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        placeIdArray.append(id)
                        
                    }
                    
                    tableView.reloadData()
                }
            }
        } catch  {
            print("error")
        }
        
    }


    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeIdArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = placeNameArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        savedPlaceName = placeNameArray[indexPath.row]
        savedPlaceId = placeIdArray[indexPath.row]
        performSegue(withIdentifier: "toMapViewController", sender: "rowselected")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! MapViewController
            if segue.identifier == "toMapViewController" && sender as! String == "rowselected"{
    
                destinationVC.placeId = savedPlaceId
                destinationVC.placeName = savedPlaceName
        }
        
        
    }
    
    @objc func addButtonClicked(){
        
        performSegue(withIdentifier: "toMapViewController", sender: "")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete{
               
               let appDelegate = UIApplication.shared.delegate as! AppDelegate
               let context = appDelegate.persistentContainer.viewContext
               
               let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
               let idString = placeIdArray[indexPath.row].uuidString
               
               fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
               fetchRequest.returnsObjectsAsFaults = false
               
               do {
                   let results = try context.fetch(fetchRequest)
                   if results.count > 0 {
                       for result in results as! [NSManagedObject]{
                           
                           if let id = result.value(forKey: "id") as? UUID{
                               if id == placeIdArray[indexPath.row]{
                                   context.delete(result)
                                   placeNameArray.remove(at: indexPath.row)
                                   placeIdArray.remove(at: indexPath.row)
                                   tableView.reloadData()
                                   
                                   do {
                                       try context.save()
                                   } catch  {
                                       print ("error")
                                   }
                                   break
                                   
                               }
                               
                           }
                           
                       }
                   }
               } catch  {
                   print("error")
               }
               
           }
           
       }
       

}

