//
//  DetailViewController.swift
//  WalkAbout
//
//  Created by Hannes Sverrisson on 14/11/2018.
//  Copyright © 2018 Hannes Sverrisson. All rights reserved.
//

import UIKit
import os

class DetailViewController: UIViewController {
    @IBOutlet weak var detailNameLabel: UILabel!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var cloudButton: UIButton!
    @IBOutlet weak var xBar: UIProgressView!
    @IBOutlet weak var yBar: UIProgressView!
    @IBOutlet weak var zBar: UIProgressView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let dataStore = DataStore.shared
    let accMeter = AcceleroMeter.shared
    var lastSessionID = 0
    
    var session: Session? {
        didSet {
            configureView()
        }
    }
    
    // Update the user interface for the session
    func configureView() {
        guard isViewLoaded else {return}
    
        if let session = self.session {
            if let label = detailNameLabel {
                label.text = session.name
            }
            if let label = detailDescriptionLabel {
                label.text = session.description
            }
            if session.saved {
                cloudButton.isEnabled = false
                cloudButton.setTitle("Saved", for: .disabled)
            } else {
                cloudButton.isEnabled = true
                cloudButton.setTitle("Save to Cloud", for: .normal)
            }
            // Disable stop button and start if not available
            stopButton.isEnabled = false
    
            if accMeter.isAvailable() {
                startButton.isEnabled = true
            } else {
                startButton.isEnabled = false
            }
        } else {
            // No session created then disable
            startButton.isEnabled = false
        }
        xBar.progress = 0
        yBar.progress = 0
        zBar.progress = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureView()
    }
    
    @IBAction func startRecordingData(_:Any) {
        stopButton.isEnabled = true
        startButton.isEnabled = false
        cloudButton.isEnabled = false
        cloudButton.setTitle("Save to Cloud", for: .disabled)
        guard let session = session else {return}
        
        // Update session to not saved
        let newSession = Session(id: session.id, clientID: session.clientID, at: session.at, name: session.name, description: session.description, saved: false)
        self.session = newSession
        dataStore.updateSession(session: newSession)
        returnSession()
        var startFrom = 4000000 * session.id
        if let sessions = dataStore.readMetadataFor(sessionID: session.id), let lastSession = sessions.last {
            startFrom = lastSession.id + 1
            os_log("Start from: %li", type: .info, startFrom)
        }
        accMeter.startFor(sessionID: session.id, from: startFrom) { [weak self](acc) in
            guard let self = self else {return}
            let range = 1.0
            self.xBar.progress = Float(acc.x / range)
            self.yBar.progress = Float(acc.y / range)
            self.zBar.progress = Float(acc.z / range)
        }
        stopButton.isEnabled = true
    }
    
    @IBAction func stopRecording(_:Any) {
        stopButton.isEnabled = false
        cloudButton.isEnabled = true
        accMeter.stopAndSaveData()
    }
    
    @IBAction func saveToCloud(_:Any) {
        guard let session = self.session else {return}
        stopRecording(true)
        self.activityIndicator.startAnimating()
        dataStore.sendToCloud(session: session) { [weak self](success) in
            guard let self = self else {return}
            if success {
                // Mark session saved
                let newSession = Session(id: session.id, clientID: session.clientID, at: session.at, name: session.name, description: session.description, saved: true)
                self.cloudButton.isEnabled = false
                self.cloudButton.setTitle("Saved", for: .disabled)
                self.session = newSession
                self.returnSession()
            } else {
                // Alert the user of the failure
                let alert = UIAlertController(title: "Not Saved!", message: "Failed sending the Session data to the server.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Make successful", style: .destructive, handler: { [weak self] (_) in
                    guard let self = self else {return}
                    // Mark session saved
                    let newSession = Session(id: session.id, clientID: session.clientID, at: session.at, name: session.name, description: session.description, saved: true)
                    self.cloudButton.isEnabled = false
                    self.cloudButton.setTitle("Saved", for: .disabled)
                    self.session = newSession
                    self.returnSession()
                }))
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            self.activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - Segues
    
    // Return the session if it has been saved
    func returnSession() {
        guard let session = self.session else {return}
        dataStore.updateSession(session: session)
        if let splitVC = self.splitViewController, let nav = splitVC.viewControllers.first as? UINavigationController {
            if let sessionsVC = nav.viewControllers.first as? SessionsViewController {
                sessionsVC.replaceSession(session: session)
            }
        }
    }
}
