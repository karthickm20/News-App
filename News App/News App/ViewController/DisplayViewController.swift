//
//  DisplayViewController.swift
//  News App
//
//  Created by Karthick M on 06/11/23.
//

import UIKit

class DisplayViewController: UIViewController {
    
    @IBOutlet var newsImage: UIImageView!
    @IBOutlet var newsTitle: UILabel!
    @IBOutlet var publishedAt: UILabel!
    @IBOutlet var authorNameAndSourceName: UILabel!
    @IBOutlet var newsDescriptionAndContent: UILabel!
    @IBOutlet var navigationTopBar: UINavigationBar!
    @IBOutlet var loadingSpinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        NetworkManager.shared.startMonitoring(controller: self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if NewsViewModel.shared.isSearching {
            let searchingData = NewsViewModel.shared.getSearchingData()[NewsViewModel.shared.indexOfSearch]
            self.navigationTopBar.topItem?.title = searchingData.source?.name
            newsTitle.text = searchingData.title
            let actualDate = NewsViewModel.shared.dateFormate(date: searchingData.publishedAt!)
            publishedAt.text = "Published at \(actualDate)"
            authorNameAndSourceName.text = "\(searchingData.author!),\(searchingData.source?.name ?? "")"
            newsDescriptionAndContent.text = "\(searchingData.description!)\n \(searchingData.content!)"
            loadingSpinner.startAnimating()
            if let urlImage = searchingData.urlToImage {
                fetchImage(urlImage: urlImage)
            }
        } else {
            let newsData = NewsViewModel.shared.getNewsData()[NewsViewModel.shared.indexOfNews]
            self.navigationTopBar.topItem?.title = newsData.source?.name
            newsTitle.text = newsData.title
            let actualDate = NewsViewModel.shared.dateFormate(date: newsData.publishedAt!)
            publishedAt.text = "published at \(actualDate)"
            authorNameAndSourceName.text = "\(newsData.author ?? ""), \(newsData.source?.name ?? "")"
            newsDescriptionAndContent.text = "\(newsData.description!)\n \(newsData.content!)"
            loadingSpinner.startAnimating()
            if let urlImage = newsData.urlToImage {
                fetchImage(urlImage: urlImage)
            }
        }
        
    }
    
    func fetchImage(urlImage: String) {
        
        APIManager.shared.APIForDownloadImage(imageURL: urlImage) { [self] image in
            loadingSpinner.stopAnimating()
            self.newsImage.image = image
        }
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
