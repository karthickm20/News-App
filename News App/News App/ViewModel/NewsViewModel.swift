//
//  NewsViewModel.swift
//  News App
//
//  Created by Karthick M on 06/11/23.
//

import Foundation

class NewsViewModel {
    
    static let shared = NewsViewModel()
    
    var newsListData = [NewsList]()
    var searchingListData = [NewsList]()
    var indexOfNews = 0
    var indexOfSearch = 0
    var isSearching = false
    
    //MARK: - CONVERT DATE FORMATE
    
    func dateFormate(date: String) -> String {
        
        let dateString = date
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatterGet.date(from: dateString)

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM d"
        if let date = date {
            let result = dateFormatterPrint.string(from: date)
            return result
        } else {
            return ""
        }
        
    }
    
    func getNewsData() -> [NewsList] {
        return newsListData
    }
    
    func getNewsDataCount() -> Int {
        return newsListData.count
    }
    
    func getSearchingData() -> [NewsList] {
        return searchingListData
    }
    
    func getSearchedDataCount() -> Int {
        return searchingListData.count
    }
}
