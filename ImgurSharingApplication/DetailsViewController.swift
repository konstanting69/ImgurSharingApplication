//
//  DetailViewController.swift
//  ImgurSharingApplication
//
//  Created by Konstantin Georgiev on 07/11/2020.
//  Copyright © 2020 Konstantin Georgiev. All rights reserved.
//

import Foundation
import UIKit

class DetailsViewController: UIViewController  {
    
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var media: Media? // used for the image details eg description
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 10
        self.imageView.clipsToBounds = true
         self.imageView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        self.descriptionTextField.clipsToBounds = true
        self.descriptionTextField.layer.cornerRadius = self.descriptionTextField.frame.size.width / 10
        self.descriptionTextField.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
       
        
        guard let image = media?.link,
            let data = try? Data(contentsOf: image) else {
                return
        }
        
        imageView.image = UIImage(data: data)
        
        descriptionTextField.text = media?.description ?? descriptionTextField.text
        viewsLabel.text = String(describing: media?.views ?? 1)
        
        
    }
    
}
