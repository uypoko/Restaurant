//
//  MenuController.swift
//  Restaurant
//
//  Created by Ryan on 6/19/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import Foundation
class MenuController {
    
    static let shared = MenuController()
    let baseURL = URL(string: "http://localhost:8090/")!
    
    func fetchCategories(completion: @escaping ([String]?) -> Void) {
        let categoryURL = baseURL.appendingPathComponent("categories")
        let task = URLSession.shared.dataTask(with: categoryURL) { (data, response, error) in
            if let data = data, let jsonDictionary = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any], let categories = jsonDictionary["categories"] as? [String] {
                completion(categories)
            } else {
                print("Something went wrong")
                completion(nil)
            }
        }
        task.resume()
    }
    
    func fetMenuItems(forCategory category: String, completion: @escaping ([MenuItem]?) -> Void) {
        let initialMenuURL = baseURL.appendingPathComponent("menu")
        var components = URLComponents(url: initialMenuURL, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "category", value: category)]
        let menuURL = components.url!
        
        let task = URLSession.shared.dataTask(with: menuURL) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data, let menuItems = try? jsonDecoder.decode(MenuItems.self, from: data) {
                completion(menuItems.items)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func submitOrder(forMenuIds menuIds: [Int], completion: @escaping (Int?) -> Void) {
        let orderURL = baseURL.appendingPathComponent("order")
        
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data: [String: [Int]] = ["menuIds": menuIds]
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(data)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data, let prepTime = try? jsonDecoder.decode(PreparationTime.self, from: data) {
                completion(prepTime.prepTime)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}
