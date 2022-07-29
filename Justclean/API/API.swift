//
//  API.swift
//  Justclean
//
//  Created by Oleg Lavronov on 26.07.2022.
//

import Foundation

struct API {
    
    let url = URL(string: "https://justclean.com")!
    
    static var config: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5.0
        config.timeoutIntervalForResource = 10.0
        return config
    }()
    
    var session: URLSession!
    
    init(_ apiURL: String) {
        self.session = URLSession(configuration: Self.config)
    }

    func get(_ route: String, params: [URLQueryItem] = [], test: Data? = nil, complete: ((Data?, URLResponse?, Swift.Error?) -> Void)? ) {
        request("GET", route, params: params, mockup: test, complete: complete)
    }

    func get<T: Codable>(_ route: String, params: [URLQueryItem] = [], complete: ((T?, Swift.Error?) -> Void)? ) {
        request("GET", route, params: params, complete: complete)
    }

    func request<T: Codable>(_ method: String,
                             _ route: String,
                             params: [URLQueryItem] = [],
                             json: [String: Any] = [:],
                             complete: ((T?, Swift.Error?) -> Void)? ) {
        
        request(method, route, params: params, json: json) { data, response, error in
            complete?(data, error)
        }
    }
    
    func request<T: Codable>(_ method: String,
                             _ route: String,
                             params: [URLQueryItem] = [],
                             json: [String: Any] = [:],
                             complete: ((T?, URLResponse?, Swift.Error?) -> Void)? ) {
        
        do {
            let body = try JSONSerialization.data(withJSONObject: json)
            request(method, route, params: params, body: body) { data, response, error in
                complete?(data, response, error)
            }
        } catch {
            dump(error)
        }
    }
    
    func request<T: Codable>(_ method: String,
                                           _ route: String,
                                           params: [URLQueryItem] = [],
                                           body: Data? = nil,
                                           complete: ((T?, URLResponse?, Swift.Error?) -> Void)? ) {
        guard let url = URLComponents(string: "\(url)/\(route)", params: params)?.url  else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        session.codableTask(with: request) { (object: T?, response, error) in
            complete?(object, response, error)
        }.resume()
    }


    
    func request(_ method: String,
                 _ route: String,
                 params: [URLQueryItem] = [],
                 body: Data? = nil,
                 mockup: Data? = nil,
                 complete: ((Data?, URLResponse?, Swift.Error?) -> Void)? ) {
        guard let url = URLComponents(string: "\(url)/\(route)", params: params)?.url  else {
            complete?(nil, nil, URLSession.Error.badRequest)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        session.dataTask(with: request) { (data, response, error) in
            complete?(data ?? mockup, response, error)
        }.resume()
    }

    
}

extension URLSession {
    
    enum Error: Swift.Error {
        case badRequest
    }
    
    func codableTask<T: Codable>(with url: URL, completion: @escaping (T?, URLResponse?, Swift.Error?) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, response, error)
                return
            }
            do {
                print(String(data: data, encoding: .utf8) ?? "")
                let object = try JSONDecoder().decode(T.self, from: data)
                completion(object, response, nil)
            } catch {
                completion(nil, response, error)
            }
        }
    }

    func codableTask<T: Codable>(with request: URLRequest, completion: @escaping (T?, URLResponse?, Swift.Error?) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, response, error)
                return
            }
            do {
                print(String(data: data, encoding: .utf8) ?? "")
                let object = try JSONDecoder().decode(T.self, from: data)
                completion(object, response, nil)
            } catch {
                completion(nil, response, error)
            }
        }
    }

}

extension URLComponents {

    public init?(string: String, params: [URLQueryItem]) {
        self.init(string: string)
        if !params.isEmpty {
            self.queryItems = params
        }
    }

}
