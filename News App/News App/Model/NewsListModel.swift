//
//  NewsDataModel.swift
//  News App
//
//  Created by Karthick M on 06/11/23.
//

import Foundation

struct NewsList : Codable {
    
    struct Source : Codable {
        let id : String?
        let name : String?
    }
    
    let source : Source?
    let author : String?
    let title : String?
    let description : String?
    let url : String?
    let urlToImage : String?
    let publishedAt : String?
    let content : String?
    
}
