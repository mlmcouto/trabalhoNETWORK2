//
//  RESTAlamofire.swift
//  Carangas
//
//  Created by Douglas Frari on 9/16/20.
//  Copyright © 2020 Eric Brito. All rights reserved.
//

import Foundation
import Alamofire


enum CarError {
    case url
    case taskError(error: Error)
    case noResponse
    case noData
    case responseStatusCode(code: Int)
    case invalidJSON
}


enum RESTOperation {
    case save
    case update
    case delete
}


class RESTAlamofire {
    
    // URL principal do servidor que obtem os dados dos carros cadastrados la
     private static let basePath = "https://carangas.herokuapp.com/cars"
     
     private static let urlFipe = "https://fipeapi.appspot.com/api/1/carros/marcas.json"
     
     
     // session criada automaticamente e disponivel para reusar
     private static let session = URLSession(configuration: configuration)
     
     
     private static let configuration: URLSessionConfiguration = {
         let config = URLSessionConfiguration.default
         config.allowsCellularAccess = true
         config.httpAdditionalHeaders = ["Content-Type":"application/json"]
         config.timeoutIntervalForRequest = 15.0
         config.httpMaximumConnectionsPerHost = 5
         return config
     }()
    
    
    
    class func loadCars(onComplete: @escaping ([Car]) -> Void, onError: @escaping (CarError) -> Void) {
        
        AF.request(REST.basePath).response { response in
            
            do {
                if response.data == nil {
                    onError(.noData)
                    return
                }
                
                if let error = response.error {
                    
                    if error.isSessionTaskError || error.isInvalidURLError {
                        onError(.url)
                        return
                    }
                    
                    if error._code == NSURLErrorTimedOut {
                        onError(.noResponse)
                    } else if error._code != 200 {
                        onError(.responseStatusCode(code: error._code))
                    }
                }
                
                let cars = try JSONDecoder().decode([Car].self, from: response.data!)
                onComplete(cars)
            } catch is DecodingError {
                onError(.invalidJSON)
            } catch {
                onError(.taskError(error: error))
            }
            
        }
        
        
    }
    
    class func save(car: Car, onComplete: @escaping (Bool) -> Void, onError: @escaping (CarError) -> Void ) {
        applyOperation(car: car, operation: .save, onComplete: onComplete, onError: onError)
    }
    
    class func update(car: Car, onComplete: @escaping (Bool) -> Void,onError: @escaping (CarError) -> Void ) {
        applyOperation(car: car, operation: .update, onComplete: onComplete, onError: onError)
    }
    
    class func delete(car: Car, onComplete: @escaping (Bool) -> Void, onError: @escaping (CarError) -> Void ) {
        applyOperation(car: car, operation: .delete, onComplete: onComplete, onError: onError)
    }
    
    
    
    
    
    
    
    
    //private
    class func applyOperation(car: Car, operation: RESTOperation , onComplete: @escaping (Bool) -> Void, onError: @escaping (CarError) -> Void ) {
        
        // o endpoint do servidor para update é: URL/id
        let urlString = REST.basePath + "/" + (car._id ?? "")
        
        guard let url = URL(string: urlString) else {
            onComplete(false)
            return
        }
        var request = URLRequest(url: url)
        var httpMethod: String = ""
        
        switch operation {
        case .delete:
            httpMethod = "DELETE"
        case .save:
            httpMethod = "POST"
        case .update:
            httpMethod = "PUT"
        }
        request.httpMethod = httpMethod
        
        
        // transformar objeto para um JSON, processo contrario do decoder -> Encoder
        guard let json = try? JSONEncoder().encode(car) else {
            onComplete(false)
            return
        }
        request.httpBody = json
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        AF.request(RESTAlamofire.basePath).response { response in
            
            if response.error == nil {
                
                guard let responseFinal = response.response else {
                    onError(.noResponse)
                    return
                }
                
                if responseFinal.statusCode == 200 {
                    
                    onComplete(true)
                    
                } else {
                    onError(.responseStatusCode(code: response.response!.statusCode))
                }
            } else {
                onError(.taskError(error: response.error!))
            }
        }
    }
    
    
} // fim da classe RESTAlamofire






        

