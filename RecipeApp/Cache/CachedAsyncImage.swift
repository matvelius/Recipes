//
//  CachedAsyncImage.swift
//  RecipeApp
//
//  Created by Matvey Kostukovsky on 10/31/24.
//

import SwiftUI

@MainActor
struct CachedAsyncImage<Content: View>: View {
    @State private var dataService = CachedImageDataService()
    
    let key: String
    let urlString: String
    let content: (AsyncImagePhase) -> Content
    
    var body: some View {
        VStack {
            switch dataService.currentState {
            case .loading:
                content(.empty)
            case .success(let image):
                content(.success(Image(uiImage: image)))
            case .failed(let error):
                content(.failure(error))
            default:
                content(.empty)
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: dataService.currentState)
        .task {
            await dataService.loadImage(with: key, imageURLString: urlString)
        }
    }
    
    init(key: String,
         urlString: String,
         @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.key = key
        self.urlString = urlString
        self.content = content
    }
    
    func refresh() async {
        await dataService.loadImage(with: key, imageURLString: urlString)
    }
    
}

enum CachedAsyncImageError: Error {
    case badData
}
