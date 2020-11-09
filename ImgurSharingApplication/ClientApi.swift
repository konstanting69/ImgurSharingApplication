//
//  ClientApi.swift
//  ImgurSharingApplication
//
//  Created by Konstantin Georgiev on 07/11/2020.
//  Copyright © 2020 Konstantin Georgiev. All rights reserved.
//
import Foundation


class Feed {
//this function helps to determine which endpoint is going to be used
    // false urltype means search, true means hot and viral, searchword parameter is going to be the word typed in the searchbar
    func loadMoreImages(urlType: Bool, page: Int = 0, searchWord: String, completion: @escaping ([Media]?) -> Void) {
        
        var url: URL?
        if urlType == true {
            url = URL(string:"https://api.imgur.com/3/gallery/hot/viral/\(page)")
        } else {
            url = URL(string:"https://api.imgur.com/3/gallery/search/viral/\(page)?q=\(searchWord)")
        }
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("Client-ID 937029c85b42e6e", forHTTPHeaderField:"Authorization") //hardcoded client ID for the imgur.com api
        //making request from the api
        URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard error == nil else {
                print("error")
                return
            }
            guard let data = data else {
                print("no data")
                return
            }
            
            
            let JsonObject = try! JSONDecoder().decode(ImageData.self, from: data)
            
            //filtering out data for videos
            let imageOnlyAlbums = JsonObject.data.filter { album in
                !(album.images?.contains { $0.type == "video/mp4" } ?? false)
            }
            //putting all images in one array
            let allImages = imageOnlyAlbums.reduce([Media]()) { result, album in
                guard let images = album.images else {
                    return result
                }
                
                return result + images
            }
            
            print(allImages)
            //returns all images in completion block
            completion(allImages)
        }.resume()
        
    }
    
}
//objects for storing json data
struct ImageData: Decodable {
    let data: [Album]
}
struct Album: Decodable {
    let images: [Media]?
}
struct Media: Decodable {
    
    let type: String
    let link: URL
    let description: String?
    let views: Int?
}
