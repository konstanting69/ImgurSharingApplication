//
//  ViewController.swift
//  ImgurSharingApplication
//
//  Created by Konstantin Georgiev on 07/11/2020.
//  Copyright © 2020 Konstantin Georgiev. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    var selectedImage: Media? // image for displaying in the details view controller
    var page = 0 //  need to keep track the page to fetch from api
    var isSearching: Bool? // need to know which endpoint we use
    var searchWord: String? // word that I need to use for the search api point
    
    
    
    
    var images: [Media]? = [
       
    ] // array of images taken from the media struct
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() // hiding keyboard when user tapps anywhere
        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        let flowLayout = UICollectionViewFlowLayout() // variable for the collection view layout
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.height/6)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        collectionView.collectionViewLayout = flowLayout
        
        //displaying all of the images when the api point is hot/viral
        // urltype is true because the user did not search thats why a empty string is passed
        Feed().loadMoreImages(urlType: true, page: page, searchWord: "") { images in
            DispatchQueue.main.async {
                self.isSearching = false
                self.images = images
                self.collectionView.reloadData()
            }
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       if searchText.count > 2 { //smoother displaying of the images while searching
        Feed().loadMoreImages(urlType: false, searchWord: searchText) { images in //displaying search results
            
            DispatchQueue.main.async {
                
                self.isSearching = true
                self.images = images
                self.collectionView.reloadData()
            }
        }
        }
        searchWord = searchText
        if searchText == "" { //when the user stops searching the app will display the hot and viral images
            Feed().loadMoreImages(urlType: true, page: page, searchWord: "") { images in
                       DispatchQueue.main.async {
                           self.isSearching = false
                           self.images = images
                           self.collectionView.reloadData()
                       }
                   }
            
        }
    }
    
    
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCustomCell", for: indexPath) as? ImageCustomCell else {
            fatalError()
        }
        
        
        guard let imageURL = images?[indexPath.item].link,//fetches image from image url
            let data = try? Data(contentsOf: imageURL) else {
            return cell
        }
        
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView?.image = UIImage(data: data)
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView?.image = UIImage(data: data)
        cell.imageView.layer.borderColor = UIColor.white.cgColor
        cell.imageView.layer.borderWidth = 1.0
        cell.imageView.layer.cornerRadius = cell.imageView.frame.size.width / 10
        cell.imageView.clipsToBounds = true
        cell.imageView.frame = cell.imageView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        
        
        return cell
    }
    
    
}
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let image = images?[indexPath.item] else {
            fatalError("Image doesn't exist!")
        }
        
        //declaring id for the storyboard to set segue
        enum Constants {
        static let detailsViewController  = "DetailsVC"
        }
        
        let detailsViewController = self.storyboard?.instantiateViewController(identifier: Constants.detailsViewController) as?
        DetailsViewController
        detailsViewController?.media = image
        
        navigationController?.pushViewController(detailsViewController!, animated: true)
    }
}

extension MainViewController: UIScrollViewDelegate {
      //this function is used to determine when to fetch a new page from the endpoint
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (collectionView.contentSize.height - (collectionView.contentOffset.y + collectionView.bounds.height) < 150) {
      //the paging needs to work for both search and viral endpoint type
            if isSearching == false {
            page += 1
            Feed().loadMoreImages(urlType: true, page: page, searchWord: "") { nextPageImages in
                DispatchQueue.main.async {
                    self.images? += nextPageImages!
                    self.collectionView.reloadData()
                }
            }
            }
            else {
                page += 1
                Feed().loadMoreImages(urlType: false, page: page, searchWord: searchWord!) { images in
                DispatchQueue.main.async {
                    self.isSearching = true
                    self.images = images
                    self.collectionView.reloadData()
            }
            }
                
            }

            
            
        }
    }
    
    
}
extension MainViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
