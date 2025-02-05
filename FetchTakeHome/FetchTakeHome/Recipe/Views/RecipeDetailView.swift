//
//  RecipeDetailView.swift
//  FetchTakeHome
//
//  Created by Donald Largen on 2/4/25.
//

import SwiftUI
import WebKit

struct RecipeDetailView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
           let webView = WKWebView()
           let request = URLRequest(url: url)
           webView.load(request)
           return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
           // You can update the web view here if needed
    }
}

#Preview {
    RecipeDetailView(url: URL(string: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ")!)
}
