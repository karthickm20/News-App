//
//  APIManager.swift
//  News App
//
//  Created by Karthick M on 06/11/23.
//

import Foundation
import Alamofire

class APIManager {
    
    static let shared = APIManager()
    
    //MARK: - API FOR FETCH ALL NEWS
    
    func APIForFetchArticle(category: String,currentPage: Int, controller: NewsViewController) {

        let url = "https://newsapi.org/v2/everything?q=\(category)&apiKey=b70c756090074baa9febbcd3d8bad7ec&page=\(currentPage)"
        let parameter: [String: Any] = [
            "q": category,
            "apiKey": "b70c756090074baa9febbcd3d8bad7ec"
        ]
        
        AF.request(url, method: .get, parameters: parameter, encoding: URLEncoding.default).response { response in
            switch response.result {
            case.success(let data):
                do {
                    defer {
                        DispatchQueue.main.async {
                            controller.isLoading = false
                            controller.loadingSpinner.stopAnimating()
                            controller.tableView.tableFooterView = nil
                            controller.tableView.reloadData()
                        }
                    }
                    if response.response?.statusCode == 200 {
                        NewsViewModel.shared.newsListData.removeAll()
                        if let data = data {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                if let articles = json["articles"] as? [[String: Any]] {
                                    for articleData in articles {
                                        if let source = articleData["source"] as? [String: Any],
                                           let sourceName = source["name"] as? String,
                                           let author = articleData["author"] as? String,
                                           let title = articleData["title"] as? String,
                                           let description = articleData["description"] as? String,
                                           let url = articleData["url"] as? String,
                                           let urlToImage = articleData["urlToImage"] as? String,
                                           let publishedAt = articleData["publishedAt"] as? String,
                                           let content = articleData["content"] as? String {
                                            DispatchQueue.main.async {
                                                NewsViewModel.shared.newsListData.append(NewsList(
                                                    source: NewsList.Source(id: nil, name: sourceName),
                                                    author: author,
                                                    title: title,
                                                    description: description,
                                                    url: url,
                                                    urlToImage: urlToImage,
                                                    publishedAt: publishedAt,
                                                    content: content
                                                ))
                                                NewsViewModel.shared.newsListData.sort { $0.title! >= $1.title! }
                                                controller.tableView.reloadData()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else if response.response?.statusCode == 401 {
                        AlertManager.shared.AlertManger(message: "Your API URL is invalid or incorrect", controller: controller)
                    } else if response.response?.statusCode == 429 {
                        AlertManager.shared.AlertManger(message: "u have made too many requests recently. Developer accounts are limited to 100 requests over a 24 hour period", controller: controller)
                    } else {
                        AlertManager.shared.AlertManger(message: "Unexpected Response Try Again", controller: controller)
                    }
                } catch {
                    AlertManager.shared.AlertManger(message: error.localizedDescription, controller: controller)
                }
            case.failure(let error):
                AlertManager.shared.AlertManger(message: error.localizedDescription, controller: controller)
            }
        }
        
    }
    
    //MARK: - API FOR DOWNLOAD IMAGE
    
    func APIForDownloadImage(imageURL: String, completion: @escaping (UIImage?) -> Void) {
        
        AF.download(imageURL).responseData { response in
            if let data = response.value, let image = UIImage(data: data) {
                completion(image)
            }
        }
        
    }
    
}
