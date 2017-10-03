//
//  WikiAPI.swift
//  SnatchDeveloperTest
//
//  Created by Shehab Saqib on 30/08/2017.
//  Copyright © 2017 Shehab Saqib. All rights reserved.
//

import Foundation

struct WikiAPI {
    
    let title:String
    let longitude:Double
    let latitude:Double
    let distance:Double
    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    init(json:[String:Any]) throws {
        guard let title = json["title"] as? String else {throw SerializationError.missing("title is missing")}
        
        guard let longitude = json["lon"] as? Double else {throw SerializationError.missing("longitude is missing")}
        
        guard let latitude = json["lat"] as? Double else {throw SerializationError.missing("latitude is missing")}
        
        guard let distance = json["dist"] as? Double else {throw SerializationError.missing("distance is missing")}
        
        self.title = title
        self.longitude = longitude
        self.latitude = latitude
        self.distance = distance
    }
    
    static func wikiURL(lat: Double, lon: Double) -> URL {
        
        let urlString = String("https://en.wikipedia.org/w/api.php?action=query&list=geosearch&gsradius=10000&gscoord=\(lat)%7C\(lon)&format=json")
        
        let url = URL(string: urlString!)
        print("\(url!)")
        
        return url!
    }
    
    static func wikiURL(name: String) -> URL {
        
        let placeName = name.components(separatedBy: " ").filter { !$0.isEmpty }.joined(separator: "_")
        
        let urlString = String("https://en.wikipedia.org/wiki/\(placeName)")
        
        let url = URL(string: urlString!)
        print("\(url!)")
        
        return url!
    }
    
    static func performSearch (lat: Double, lon: Double, completion: @escaping ([WikiAPI]) -> ()) {
            
        let url = wikiURL(lat: lat, lon: lon)
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                var searchArray:[WikiAPI] = []
            
                //Pyramid of doom :(
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            if let query = json["query"] as? [String:Any] {
                                if let geosearch = query["geosearch"] as? [[String:Any]] {
                                    for searchTerms in geosearch {
                                        if let geo = try? WikiAPI(json: searchTerms) {
                                            searchArray.append(geo)
                                        }
                                    }
                                }
                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                    completion(searchArray)
                }
        }
        task.resume()
    }
}
