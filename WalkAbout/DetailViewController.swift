//
//  DetailViewController.swift
//  WalkAbout
//
//  Created by Hannes Sverrisson on 14/11/2018.
//  Copyright © 2018 Hannes Sverrisson. All rights reserved.
//

import UIKit

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
    var lastSessionID: Int32 = 0
    
    var session: Session? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the session
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
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        // Disable stop button and start if not available
        stopButton.isEnabled = false
        cloudButton.isEnabled = false
        if accMeter.isAvailable() {
            startButton.isEnabled = true
        } else {
            startButton.isEnabled = false
            startButton.setTitle("Not Available", for: .disabled)
        }
        xBar.progress = 0
        yBar.progress = 0
        zBar.progress = 0
    }
    
    @IBAction func startRecordingData(_:Any) {
        stopButton.isEnabled = true
        startButton.isEnabled = false
        guard let session = session else {return}
        accMeter.startFor(sessionID: session.id, from: 0) { [weak self](acc) in
            guard let self = self else {return}
            let range = 1.0
            self.xBar.progress = Float(acc.x / range)
            self.yBar.progress = Float(acc.y / range)
            self.zBar.progress = Float(acc.z / range)
        }
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
                print("newSession: \(newSession)")
                self.cloudButton.isEnabled = false
                self.cloudButton.setTitle("Saved", for: .disabled)
                self.session = newSession
            }
            self.activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - Segues
    
    // Return the session if it has been saved
    override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        guard let session = self.session else {return}
        if session.saved {
            if let nav = subsequentVC as? UINavigationController {
                if let master = nav.topViewController as? SessionsViewController {
                    master.replaceSession(session: session)
                }
            }
        }
    }
}
