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
    
    var serverDomain = "localhost:3000"
    let pathname = "/client/"
    
    func fetchData(clientID: String, callback: @escaping (Client?, URLResponse?, Error?) -> Void) throws -> Void {
        let href: String = serverDomain + pathname + clientID
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
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
        let href: String = serverDomain + pathname
        let semaphore = DispatchSemaphore(value: 0)
        var success = false
        
        if let url = URL(string: href) {
            os_log("POST href: %@", type: .debug, url.absoluteString)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Upload data
            let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
                if let error = error {
                    os_log("POST error: %@", type: .error, error.localizedDescription)
                    return
                }
                guard let response = response as? HTTPURLResponse,
                    (200...299).contains(response.statusCode) else {
                        os_log("POST Server error", type: .error)
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
