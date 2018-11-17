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
    let pathname = "/Client/"
    
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

}
