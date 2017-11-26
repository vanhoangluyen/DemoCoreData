//
//  MasterTVC.swift
//  DemoCoreData
//
//  Created by HoangLuyen on 11/23/17.
//  Copyright © 2017 HoangLuyen. All rights reserved.
//

import UIKit
import CoreData

class MasterTVC: UITableViewController, NSFetchedResultsControllerDelegate {

    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addName))
        self.navigationItem.rightBarButtonItem = addButton
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    @objc func addName() {
        let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            guard let textField = alert.textFields?.first, let nameToSave = textField.text else { return }
            let context = self.fetchedResultsController.managedObjectContext
            let newPerson = Person(context: context)
            // If appropriate, configure the new managed object
            newPerson.name = nameToSave
            //save context
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Unresolve error \(error) , \(error.userInfo)")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let person = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withPerson: person)
        return cell
    }
    //MARK: - configure cell
    func configureCell(_ cell: UITableViewCell , withPerson person: Person) {
        cell.textLabel?.text = person.name!.description
    }
    //MARK: -FetchResult controller
    var fetchedResultsController: NSFetchedResultsController<Person> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        // Set batch size to a suitable number
        fetchRequest.fetchBatchSize = 20
        // Edit sort key as appropriate
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        // Edit the section name key path and cahce name if appropriate
        // nil for section name key path means "no sections"
        let afetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: AppDelegate.shared.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: "Master")
        afetchedResultsController.delegate = self
        _fetchedResultsController = afetchedResultsController
        do {
            try _fetchedResultsController!.performFetch()
        } catch let error  as NSError {
            // Replace this implementtation with code to handle the error appropriately
            // fatalError() causes the application to generate a crash to log and terminate. You should not use this function in a shipping application, although it may be useful during development
            fatalError("Unresolved error \(error) , \(error.userInfo)")
        }
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<Person>? = nil
    //MARK: -fetched Results Controller Delegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(tableView.cellForRow(at: indexPath!)!, withPerson: anObject as! Person)
        case .move:
            configureCell(tableView.cellForRow(at: indexPath!)!, withPerson: anObject as! Person)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    //MARK: -editing tableView
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //Delete the row from dataSource
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    //MARK: -segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = segue.destination as! DetailVC
                controller.detailItem = object
            }       
        }
    }
}
