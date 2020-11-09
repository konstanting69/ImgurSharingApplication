//
//  ImgurSharingApplicationTests.swift
//  ImgurSharingApplicationTests
//
//  Created by Konstantin Georgiev on 09/11/2020.
//  Copyright © 2020 Konstantin Georgiev. All rights reserved.
//

import XCTest
@testable import ImgurSharingApplication

class ImgurSharingApplicationTests: XCTestCase {
    
    func testDecodable() {
        
        let fileURL = Bundle(for: Self.self).url(forResource: "viral", withExtension: "json")
        let data = try! Data(contentsOf: fileURL!)
        let JsonObject = try! JSONDecoder().decode(ImageData.self, from: data)
        XCTAssertEqual(JsonObject.data.count, 2)
      
        XCTAssertEqual(JsonObject.data.first?.images?.count, 1)
        
        XCTAssertEqual(JsonObject.data.first?.images?.first?.link, URL(string: "https://i.imgur.com/8yHSxt4.jpg"))
        
    }

    

}
