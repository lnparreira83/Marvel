//
//  WebView.swift
//  Marvel
//
//  Created by Lucas Parreira on 27/06/21.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    
    var url: URL
    
    func makeUIView(context: Context) -> WKWebView {
     let view = WKWebView()
     view.load(URLRequest(url: url))
     
     return view
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        //
    }
}

