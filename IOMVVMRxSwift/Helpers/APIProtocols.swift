//
//  APIProtocols.swift
//  IOMVVMRxSwift
//
//  Created by D2k on 30/05/19.
//  Copyright © 2019 ajaybhanushali. All rights reserved.
//

import Foundation
import RxSwift

struct APIRequest {
    var method: RequestType
    var path: String
    var parameters: Codable?
}

public enum RequestType: String {
    case GET, POST
}

extension APIRequest {
    func request(with baseURL: URL) -> URLRequest {
        guard let components = URLComponents(url: path.contains("http") ? URL(string: path)! : baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            fatalError("Unable to create URL components")
        }
        
        guard let url = components.url else {
            fatalError("Could not get url")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let parameters = parameters {
            let requestJSON = try? parameters.encode()
            request.httpBody = requestJSON!
        }
        
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        headers["version"] = "v2"
        
        request.allHTTPHeaderFields = headers
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}

class APIClient {
    
    private let baseURL = URL(string: APIConstants.domain.rawValue)!
    
    func send<T: Codable>(apiRequest: APIRequest) -> Observable<T> {
        return Observable<T>.create { observer in
            let request = apiRequest.request(with: self.baseURL)
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data, let utf8Representation = String(data: data, encoding: .utf8) {
                    print("response: ", utf8Representation)
                } else {
                    print("no readable data received in response")
                }
                
                do {
                    let model: T = try JSONDecoder().decode(T.self, from: data ?? Data())
                    observer.onNext(model)
                } catch let error {
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
