//
//  ComicsView.swift
//  Marvel
//
//  Created by Lucas Parreira on 27/06/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct ComicsView: View {
    @EnvironmentObject var homeData: HomeViewModel
    
    var body: some View {
        NavigationView{
            ScrollView(.vertical, showsIndicators: false, content: {
                if homeData.fetchedComics.isEmpty {
                    
                    ProgressView()
                        .padding(.top,30)
                    
                }
                else {
                    
                    VStack(spacing: 15){
                        ForEach(homeData.fetchedComics){ comic in
                            
                            ComicRowView(character: comic)
                            
                            }
                        
                        // Infinity Scroll Using Geometry Reader
                        
                        if homeData.offset == homeData.fetchedComics.count{
                            // showing progress and fetching new data
                            
                            ProgressView()
                            padding(.vertical)
                                .onAppear(perform:{
                                    print("fetching new data...")
                                    homeData.fetchComics()
                                })
                        }
                        else {
                            GeometryReader{ reader -> Color in
                                let minY = reader.frame(in: .global).minY
                                let height = UIScreen.main.bounds.height / 1.3
                                
                                // when it goes over the height triggering update
                                if !homeData.fetchedComics.isEmpty && minY < height {
                                    print("last")
                                    DispatchQueue.main.async {
                                        homeData.offset = homeData.fetchedComics.count
                                    }
                                    
                                }
                                
                                return Color.clear
                            }
                            .frame(width:20,height:20)
                        }
                    }
                    .padding(.vertical)
                }
            })
            .navigationTitle("marvel's Comics")
        }
        .onAppear(perform: {
            if homeData.fetchedComics.isEmpty{
                homeData.fetchComics()
            }
        })
    }
}

struct ComicsView_Previews: PreviewProvider {
    static var previews: some View {
        ComicsView()
            .environmentObject(HomeViewModel())
    }
}

struct ComicRowView: View {
    
    var character: Comic
    
    var body: some View {
        HStack(alignment:.top,spacing:15){
            WebImage(url: extractImage(data: character.thumbnail))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width:150, height: 150)
                .cornerRadius(8)
            
            VStack(alignment:.leading, spacing: 8, content:{
                Text(character.title)
                    .font(.title3)
                    .fontWeight(.bold)
                
                if let description = character.description {
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                }
                
                // Links
                HStack(spacing: 10){
                    ForEach(character.urls, id: \.self){ data in
                        
                        NavigationLink(
                            destination: WebView(url: extractURL(data: data))
                                .navigationTitle(extractURLType(data: data)),
                            label: {
                                Text(extractURLType(data: data))
                            })
                    }
                }
            })
            Spacer(minLength: 0)
        }
        .padding(.horizontal)
    }
    
    func extractImage(data: [String:String])-> URL {
        let path = data["path"] ?? ""
        let ext = data["extension"] ?? ""
        print("\(path).\(ext)")
        return URL(string: "\(path).\(ext)")!
        
    }
    
    func extractURL(data: [String:String])->URL {
        let url = data["url"] ?? ""
        return URL(string: url)!
    }
    
    func extractURLType(data: [String:String])->String{
        let type = data["type"] ?? ""
        
        return type.capitalized
    }
}
