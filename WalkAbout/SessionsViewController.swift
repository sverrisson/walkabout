//
//  SessionViewController.swift
//  WalkAbout
//
//  Created by Hannes Sverrisson on 14/11/2018.
//  Copyright © 2018 Hannes Sverrisson. All rights reserved.
//

import UIKit
import os
import SQLite

class SessionsViewController: UITableViewController {
    var detailViewController: DetailViewController? = nil
    var sessions:[Session] = []
    var dataStore = DataStore.shared
    private var dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    private var lastSessionID = 0
    private var client: Client?

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
        
        // Import all stored sessions
        if let sessions = dataStore.readAllSessions(), let last = sessions.last {
            self.sessions = sessions
            lastSessionID = last.id
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let client = dataStore.readClient() {
            self.client = client
            os_log("Client: %@", type: .debug, client.description)
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
            var description = ""
            if let textFields = alert?.textFields {
                textFields.forEach({ (textField) in
                    if let text = textField.text, text.count > 0 {
                        if textField.tag == 1 {
                            name = text
                        } else {
                            description = text
                        }
                    }
                })
            }
            // Create Session
            let defaults = UserDefaults.standard
            if defaults.integer(forKey: Constants.sessionIdKeys) > 0 {
                self.lastSessionID = defaults.integer(forKey: Constants.sessionIdKeys)
                // Update for next Session
                defaults.set(self.lastSessionID + 1, forKey: Constants.sessionIdKeys)
            }
            let sessionID = self.lastSessionID + 1
            if let client = self.client {
                let session = Session(id: sessionID, clientID: client.id, at: Date(), name: name, description: description, saved: false)
                self.insertNewSession(session: session)
                self.dataStore.storeSession(session: session)
            } else {
                if let client = self.dataStore.readClient() {
                    self.client = client
                    let session = Session(id: sessionID, clientID: client.id, at: Date(), name: name, description: description, saved: false)
                    self.insertNewSession(session: session)
                    self.dataStore.storeSession(session: session)
                }
            }
            self.lastSessionID += 1
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func insertNewSession(session: Session) {
        sessions.insert(session, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func replaceSession(session: Session) {
        if let selected = tableView.indexPathForSelectedRow {
            sessions[selected.item] = session
            tableView.reloadRows(at: [selected], with: .automatic)
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let session = sessions[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.session = session
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
        if session.saved {
            cell.tintColor = .green
        } else {
            cell.tintColor = .red
        }
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

