//
//  HomeViewModel.swift
//  Marvel
//
//  Created by Lucas Parreira on 27/06/21.
//

import SwiftUI
import Combine
import CryptoKit

class HomeViewModel: ObservableObject {
    @Published var searchQuery = ""
    
    // used to cancel the search publisher when ever we need
    var searchCancellable: AnyCancellable? = nil
    
    // fetched Data...
    @Published var fetchedCharacters: [Character]? = nil
    
    // Comic View Data...
    @Published var fetchedComics: [Comic] = []
    
    @Published var offset: Int = 0
    
    init(){
        searchCancellable = $searchQuery
            .removeDuplicates()
            .debounce(for: 0.6, scheduler: RunLoop.main)
            .sink(receiveValue: { str in
                if str == "" {
                    // reset Data
                    self.fetchedCharacters = nil
                }
                else {
                    self.searchCharacter()
                    
                }
            })
    }
    
    func searchCharacter(){
        let ts = String(Date().timeIntervalSince1970)
        let hash = MD5(data: "\(ts)\(privateKey)\(publicKey)")
        
        let originalQuery = searchQuery.replacingOccurrences(of: " ", with: "%20")
        let url = "https://gateway.marvel.com:443/v1/public/characters?nameStartsWith=\(originalQuery)&ts=\(ts)&apikey=\(publicKey)&hash=\(hash)"
        
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: URL(string: url)!) { (data, _, err) in
            if let error = err{
                print(error.localizedDescription)
                return
            }
            guard let APIData = data else {
                print("no data found")
                return
            }
            
            do{
                // decoding
                let characters = try JSONDecoder().decode(APIResult.self, from: APIData)
                DispatchQueue.main.async {
                    if self.fetchedCharacters == nil {
                        self.fetchedCharacters = characters.data.results
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        .resume()
    }
    
    // to generate Hash were going to use cryptoKit...
    func MD5(data: String)-> String {
        let hash = Insecure.MD5.hash(data: data.data(using: .utf8) ?? Data())
        
        return hash.map {
            String(format: "%02hhx", $0)
        }
        .joined()
    }
    
    func fetchComics(){
        
        let ts = String(Date().timeIntervalSince1970)
        let hash = MD5(data: "\(ts)\(privateKey)\(publicKey)")

        let url = "https://gateway.marvel.com:443/v1/public/comics?limit=20&offset=\(offset)&ts=\(ts)&apikey=\(publicKey)&hash=\(hash)"
        
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: URL(string: url)!) { (data, _, err) in
            if let error = err{
                print(error.localizedDescription)
                return
            }
            guard let APIData = data else {
                print("no data found")
                return
            }
            
            do{
                // decoding
                let characters = try JSONDecoder().decode(APIComicResult.self, from: APIData)
                DispatchQueue.main.async {
                    self.fetchedComics.append(contentsOf: characters.data.results)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        .resume()
    }
}































