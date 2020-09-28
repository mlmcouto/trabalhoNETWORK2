//
//  REST.swift
//  Carangas
//
//  Created by Douglas Frari on 8/27/20.
//  Copyright © 2020 Eric Brito. All rights reserved.
//

import Foundation


//enum CarError {
//    case url
//    case taskError(error: Error)
//    case noResponse
//    case noData
//    case responseStatusCode(code: Int)
//    case invalidJSON
//}
//
//
//enum RESTOperation {
//    case save
//    case update
//    case delete
//}

class REST {
    
    // URL principal do servidor que obtem os dados dos carros cadastrados la
    public static let basePath = "https://carangas.herokuapp.com/cars"
    
    public static let urlFipe = "https://fipeapi.appspot.com/api/1/carros/marcas.json"
    
    
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
    
    private class func loadCars(onComplete: @escaping ([Car]) -> Void, onError: @escaping (CarError) -> Void) {
        
        guard let url = URL(string: basePath) else {
            onError(.url)
            return
        }
        
        let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            // usamos uma closure para receber as respostas, ou seja, estamos em um processo
            // em background que será assincrono
            
            // 1
            if error == nil {
                // 2
                guard let response = response as? HTTPURLResponse else {
                    onError(.noResponse)
                    return
                }
                if response.statusCode == 200 {
                    
                    // servidor respondeu com sucesso :)
                    // 3
                    // obter o valor de data
                    guard let data = data else {
                        onError(.noData)
                        return
                    }
                    
                    do {
                        
                        let cars = try JSONDecoder().decode([Car].self, from: data)
                        // pronto para reter dados
                        
                        onComplete(cars)                        
                        
                    } catch {
                        // algum erro ocorreu com os dados
                        onError(.invalidJSON)
                    }
                    
                    
                } else {
                    onError(.responseStatusCode(code: response.statusCode))
                }
                
            } else {
                onError(.taskError(error: error!))
            }
            
        }
        
        // start request
        dataTask.resume()
    }
    
    
//        class func save(car: Car, onComplete: @escaping (Bool) -> Void ) {
//            applyOperation(car: car, operation: .save, onComplete: onComplete)
//        }
//    
//        class func update(car: Car, onComplete: @escaping (Bool) -> Void ) {
//            applyOperation(car: car, operation: .update, onComplete: onComplete)
//        }
//    
//        class func delete(car: Car, onComplete: @escaping (Bool) -> Void ) {
//            applyOperation(car: car, operation: .delete, onComplete: onComplete)
//        }
    
    
    private class func applyOperation(car: Car, operation: RESTOperation , onComplete: @escaping (Bool) -> Void ) {
        
        // o endpoint do servidor para update é: URL/id
        let urlString = basePath + "/" + (car._id ?? "")
        
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
        
        let dataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if error == nil {
                // verificar e desembrulhar em uma unica vez
                guard let response = response as? HTTPURLResponse, response.statusCode == 200, let _ = data else {
                    onComplete(false)
                    return
                }
                
                // ok
                onComplete(true)
                
            } else {
                onComplete(false)
            }
        }
        
        dataTask.resume()
    }
    
    
    // o metodo pode retornar um array de nil se tiver algum erro
    class func loadBrands(onComplete: @escaping ([Brand]?) -> Void) {
        
        // URL TABELA FIPE
        
        guard let url = URL(string: urlFipe) else {
            onComplete(nil)
            return
        }
        // tarefa criada, mas nao processada
        let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if error == nil {
                guard let response = response as? HTTPURLResponse else {
                    onComplete(nil)
                    return
                }
                if response.statusCode == 200 {
                    // obter o valor de data
                    guard let data = data else {
                        onComplete(nil)
                        return
                    }
                    do {
                      let brands = try JSONDecoder().decode([Brand].self, from: data)
                        onComplete(brands)
                    } catch {
                        // algum erro ocorreu com os dados
                        onComplete(nil)
                    }
                } else {
                    onComplete(nil)
                }
            } else {
                onComplete(nil)
            }
        }
        // start request
        dataTask.resume()
    }
    
    
    
} // fim da classe REST
