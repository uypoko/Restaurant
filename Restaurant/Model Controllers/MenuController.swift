//
//  MenuController.swift
//  Restaurant
//
//  Created by Ryan on 6/19/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import Foundation
import UIKit
class MenuController {
    
    static let shared = MenuController()
    let baseURL = URL(string: "http://localhost:8090/")!
    static let orderUpdateNotification = Notification.Name("MenuController.orderUpdated")
    var order = Order() {
        didSet {
            NotificationCenter.default.post(name: MenuController.orderUpdateNotification, object: nil)
        }
    }
    private static let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let orderFileURL = documentsDirectoryURL.appendingPathComponent("order").appendingPathExtension("json")
    private let menuItemsFileURL = documentsDirectoryURL.appendingPathComponent("menuItems").appendingPathExtension("json")
    private var itemsById = [Int: MenuItem]()
    private var itemsByCategory = [String: [MenuItem]]()
    static let menuDataUpdatedNotification = Notification.Name("MenuController.menuDataUpdated")
    
    func fetchImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
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
    
    func loadOrder() {
        guard let data = try? Data(contentsOf: orderFileURL) else { return }
        order = (try? JSONDecoder().decode(Order.self, from: data)) ?? Order(menuItems: [])
    }
    
    func saveOrder() {
        if let data = try? JSONEncoder().encode(order) {
            try? data.write(to: orderFileURL)
        }
    }
    
    func item(withId itemId: Int) -> MenuItem? {
        return itemsById[itemId]
    }
    
    func items(forCategory category: String) -> [MenuItem]? {
        return itemsByCategory[category]
    }
    
    var categories: [String] {
        get {
            return itemsByCategory.keys.sorted()
        }
    }
    
    private func process(items: [MenuItem]) {
        itemsById.removeAll()
        itemsByCategory.removeAll()
        
        for item in items {
            itemsById[item.id] = item
            itemsByCategory[item.category, default: []].append(item)
        }
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: MenuController.menuDataUpdatedNotification, object: nil)
        }
    }
    
    func loadRemoteData() {
        let initialMenuURL = baseURL.appendingPathComponent("menu")
        let components = URLComponents(url: initialMenuURL, resolvingAgainstBaseURL: true)!
        let menuURL = components.url!
        
        let task = URLSession.shared.dataTask(with: menuURL) { (data, _, _) in
            let jsonDecoder = JSONDecoder()
            if let data = data, let menuItems = try? jsonDecoder.decode(MenuItems.self, from: data) {
                self.process(items: menuItems.items)
            }
        }
        task.resume()
    }
    
    func loadItems() {
        guard let data = try? Data(contentsOf: menuItemsFileURL) else { return }
        let items = (try? JSONDecoder().decode([MenuItem].self, from: data)) ?? []
        process(items: items)
    }
    
    func saveItems() {
        let items = Array(itemsById.values)
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: menuItemsFileURL)
        }
    }
}
