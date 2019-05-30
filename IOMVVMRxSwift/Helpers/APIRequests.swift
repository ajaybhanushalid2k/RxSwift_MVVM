//
//  APIRequests.swift
//  UrbanKalyani
//
//  Created by Ajay Bhanushali on 14/12/18.
//  Copyright © 2018 D2K Technologies. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum APIConstants: String {
    case domain          = "http://219.90.67.69:8011/OrderManagement_API/api/"
    case requestProducts = "Product/InStock"
}

class APIRequests {
    
    static let shared = APIRequests()
    
    private init(){}
    
    func get(requestURL: String, callBack:@escaping ((Error?, Data?)->Void)) {
        guard let url = URL(string: requestURL) else { return }
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("v2", forHTTPHeaderField: "version")
        
        URLSession.shared.dataTask(with: request as URLRequest) { (responseData, response, responseError) in
            guard responseError == nil else {
                callBack(responseError!, nil)
                return
            }
            
            if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                print("response: ", utf8Representation)
                callBack(nil, data)
            } else {
                print("no readable data received in response")
            }
            }.resume()
    }
    
    func post<T>(requestModel: T, requestPath: APIConstants, callBack:@escaping ((Error?, Data?)->Void)) {
        let url = URL(string: APIConstants.domain.rawValue + requestPath.rawValue)!
        
        
        // Configure post request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        headers["version"] = "v2"
        
        request.allHTTPHeaderFields = headers
        let requestJSON = try? (requestModel as? Encodable)?.encode()
        request.httpBody = requestJSON!
        
        // Create and run a URLSession data task with our JSON encoded POST request
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else {
                callBack(responseError!, nil)
                return
            }
            if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                print("response: ", utf8Representation)
                callBack(nil, data)
            } else {
                print("no readable data received in response")
            }
        }
        task.resume()
    }
}

extension Encodable {
    func encode(with encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        encoder.keyEncodingStrategy = .useDefaultKeys
        return try encoder.encode(self)
    }
}

extension Decodable {
    static func decode(with decoder: JSONDecoder = JSONDecoder(), from data: Data) throws -> Self {
        return try decoder.decode(Self.self, from: data)
    }
}
