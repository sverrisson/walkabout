//
//  NetworkClient.swift
//  ruvSpilari
//
//  Created by Hannes Sverrisson on 13/09/2018.
//  Copyright © 2018 Rikisutvarpid. All rights reserved.
//

import UIKit
import os

enum APIRequestError: Error {
    case url(url: String?)
    case parsing(error: Error?)
    case network(error: Error?)
}

// NetworkClient singleton handles all network traffic in and out
class NetworkClient {
    static var shared = NetworkClient()
    private var serverDomain = "http://10.0.1.4:3000"
    private let pathname = "/session"
    
    init() {
        // Check if Server Domain is set in settings
        let defaults = UserDefaults.standard
        if let serverDomain = defaults.string(forKey: Constants.serverDomainKey) {
            os_log("Server domain from settings: %@", type: .info, serverDomain)
            self.serverDomain = serverDomain
        }
    }
    
    func fetchData(clientID: String, callback: @escaping (Client?, URLResponse?, Error?) -> Void) throws -> Void {
        let href: String = serverDomain + pathname + clientID
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 8
        let session = URLSession(configuration: config)
        
        if let url = URL(string: href) {
            os_log("Fetching href: %@", type: .debug, url.absoluteString)
            session.dataTask(with: url) { (data, response, error) in
                guard let data = data else {
                    os_log("Network fetch error", type: .error)
                    callback(nil, response, error)
                    return
                }
                var client: Client? = nil
                do {
                    client = try JSONDecoder().decode(Client.self, from: data)
                } catch {
                    DispatchQueue.main.async {
                        callback(nil, response, nil)
                    }
                    os_log("Error in JSON Model: %@", type: .error, error.localizedDescription)
                    return
                }
                if let client = client {
                    DispatchQueue.main.async {
                        callback(client, response, nil)
                    }
                } else {
                    os_log("Client did not decode: %@", type: .error)
                }
                }.resume()
        } else { throw APIRequestError.url(url: href) }
    }
    
    // Send data and return the success
    func sendDataSynchronously(_ uploadData: Data) -> Bool {
        // Check if Server Domain has changed in settings
        let defaults = UserDefaults.standard
        if let serverDomain = defaults.string(forKey: Constants.serverDomainKey) {
            os_log("Server domain from settings: %@", type: .info, serverDomain)
            self.serverDomain = serverDomain
        }
        
        let href: String = serverDomain + pathname
        let semaphore = DispatchSemaphore(value: 0)
        var success = false
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 8
        let session = URLSession(configuration: config)
        
        if let url = URL(string: href) {
            os_log("POST href: %@", type: .debug, url.absoluteString)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Upload data
            let task = session.uploadTask(with: request, from: uploadData) { data, response, error in
                if let error = error {
                    os_log("POST error: %@", type: .error, error.localizedDescription)
                    semaphore.signal()
                }
                guard let response = response as? HTTPURLResponse else {
                    os_log("POST Server error", type: .error)
                    semaphore.signal()
                    return
                }
                os_log("Server statusCode: %li", type: .debug, response.statusCode)
                guard (200...299).contains(response.statusCode) else {
                    os_log("POST Server error", type: .error)
                    semaphore.signal()
                    return
                }
                if let mimeType = response.mimeType,
                    mimeType == "application/json",
                    let data = data,
                    let dataString = String(data: data, encoding: .utf8) {
                    os_log("Server response: %@", type: .error, dataString)
                    success = true
                    semaphore.signal()
                }
            }
            task.resume()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return success
    }
}
