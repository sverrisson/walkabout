//
//  SessionViewController.swift
//  WalkAbout
//
//  Created by Hannes Sverrisson on 14/11/2018.
//  Copyright © 2018 Hannes Sverrisson. All rights reserved.
//

import UIKit
import os

class SessionViewController: UITableViewController {
    var detailViewController: DetailViewController? = nil
    var sessions:[(name: String, description: String)] = []
    var dataStore = DataStore.shared
    private var dateFormatter = ISO8601DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(getName(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let client = dataStore.readClient() {
            os_log("Client: %@", type: .debug, client.description)
        }
        
        DispatchQueue.main.async {
            let acc = AcceleroMeter.shared
            acc.startFor(sessionID: 123, from: 0)
        }
        super.viewDidAppear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    @objc
    func getName(_ sender: Any) {
        let alert = UIAlertController(title: "Session Name?", message: "Give the session a name and a description:", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
            textField.placeholder = "Name"
            textField.tag = 1
        }
        alert.addTextField { (textField) in
            textField.text = ""
            textField.placeholder = "Description"
            textField.tag = 2
        }
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alert] (_) in
            // Save the date and time if the user returns the field empty
            var name = self.dateFormatter.string(from: Date())
            var description = self.dateFormatter.string(from: Date())
            if let textFields = alert?.textFields {
                textFields.forEach({ (textField) in
                    if let text = textField.text, text.count > 0 {
                        print("Text field: \(text)")
                        if textField.tag == 1 {
                            name = text
                        } else {
                            description = text
                        }
                    }
                })
            }
            self.insertNewSession(session: (name: name, description: description))
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func insertNewSession(session: (name: String, description: String)) {
        sessions.insert(session, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let session = sessions[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = session
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let session = sessions[indexPath.row]
        cell.textLabel!.text = session.name
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            sessions.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

