//
//  ViewController.swift
//  News App
//
//  Created by Karthick M on 06/11/23.
//

import UIKit

class NewsViewController: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var sortingButtonTapped: UIBarButtonItem!
    @IBOutlet var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet var filterButtonTapped: UIBarButtonItem!
    
    var topRefreshController = UIRefreshControl()
    
    let categories = ["sports", "science", "economy", "space", "history"]
    var currentlySelectedCategory = "economy"
    var currentPage = 1
    var totalPages = 5
    var isSortbuttonTapped = true
    var isLoading = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setUI()
        let nib = UINib(nibName: "NewsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "NewsTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        topRefreshController.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.refreshControl = topRefreshController
        
        view.addSubview(loadingSpinner)
        loadingSpinner.startAnimating()
        APIManager.shared.APIForFetchArticle(category: currentlySelectedCategory, currentPage: currentPage, controller: self)
        
    }
    
    @objc func refresh(send: UIRefreshControl) {
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.topRefreshController.endRefreshing()
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        NetworkManager.shared.startMonitoring(controller: self)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        if NewsViewModel.shared.getNewsDataCount() == 0 {
            tableView.isHidden = true
        }
        
    }
    
    //MARK: - FILTER BUTTON
    @IBAction func filterTheNews(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Select a category", message: nil, preferredStyle: .actionSheet)
        for category in categories {
            let action = UIAlertAction(title: category, style: .default) { _ in
                self.currentlySelectedCategory = category
                self.currentPage = 1
                self.loadingSpinner.startAnimating()
                APIManager.shared.APIForFetchArticle(category: category, currentPage: self.currentPage, controller: self)
            }
            alertController.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    //MARK: - SORT BUTTON
    @IBAction func sortTheNews(_ sender: Any) {
        
        if isSortbuttonTapped {
            sortingButtonTapped.image = UIImage(named: "asc")
            NewsViewModel.shared.newsListData.sort { $0.title! <= $1.title! }
            tableView.reloadData()
            isSortbuttonTapped = false
        } else {
            self.sortingButtonTapped.image = UIImage(named: "dsc")
            NewsViewModel.shared.newsListData.sort { $0.title! >= $1.title! }
            self.tableView.reloadData()
            self.isSortbuttonTapped = true
        }
        
    }
    
    func setUI() {
        
        tableView.separatorStyle = .none
        searchBar.layer.cornerRadius = 10
        searchBar.layer.masksToBounds = true
        searchBar.autocapitalizationType = .none
        
    }
    
}

//MARK: - EXTENSION FOR TABLEVIEW
extension NewsViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if NewsViewModel.shared.isSearching {
            return NewsViewModel.shared.getSearchingData().count
        } else {
            return NewsViewModel.shared.getNewsData().count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as! NewsTableViewCell
        if NewsViewModel.shared.isSearching {
            let searchingData = NewsViewModel.shared.getSearchingData()[indexPath.row]
            cell.newsContent.text = searchingData.title
            let actualDate = NewsViewModel.shared.dateFormate(date: searchingData.publishedAt!)
            cell.published.text = "Published at \(actualDate)"
            if let urlImage = searchingData.urlToImage {
                APIManager.shared.APIForDownloadImage(imageURL: urlImage) { image in
                    if let image = image {
                        cell.newsImage.image = image
                    }
                }
            }
        } else {
            let newsData = NewsViewModel.shared.getNewsData()[indexPath.row]
            cell.newsContent.text = newsData.title
            let actualDate = NewsViewModel.shared.dateFormate(date: newsData.publishedAt!)
            cell.published.text = "Published at \(actualDate)"
            if let urlImage = newsData.urlToImage {
                APIManager.shared.APIForDownloadImage(imageURL: urlImage) { image in
                    if let image = image {
                        cell.newsImage.image = image
                    }
                }
            }
        }
        tableView.isHidden = false
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 102
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if NewsViewModel.shared.isSearching {
            NewsViewModel.shared.indexOfSearch = indexPath.row
        } else {
            NewsViewModel.shared.indexOfNews = indexPath.row
        }
        let storyBoard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DisplayViewController") as! DisplayViewController
        self.navigationController?.pushViewController(storyBoard, animated: true)
        
    }
    
    private func createSpinnerFooter() -> UIView {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        if offsetY > contentHeight - height && currentPage < totalPages, !isLoading {
            isLoading = true
            tableView.tableFooterView = createSpinnerFooter()
            currentPage += 1
            APIManager.shared.APIForFetchArticle(category: currentlySelectedCategory, currentPage: currentPage, controller: self)
        }
    }
    
}

//MARK: - EXTENSION FOR SEARCHBAR
extension NewsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        NewsViewModel.shared.searchingListData = NewsViewModel.shared.newsListData.filter({($0.title?.lowercased().prefix(searchText.count))! == searchText})
        if searchText.isEmpty {
            NewsViewModel.shared.isSearching = false
        } else {
            NewsViewModel.shared.isSearching = true
        }
        tableView.reloadData()
        
    }
    
}
