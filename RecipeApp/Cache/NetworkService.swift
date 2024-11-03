//
//  NetworkService.swift
//  RecipeApp
//
//  Created by Matvey Kostukovsky on 10/29/24.
//

import UIKit

protocol NetworkServiceProtocol {
    associatedtype T
    func retrieveImage(using urlString: String) async throws -> UIImage?
    func fetchData<T: Decodable>(for urlString: String) async throws -> T
}

public final class NetworkService: NetworkServiceProtocol {
    typealias T = Response
    
    public static let shared = NetworkService()
    
    private var urlSession: URLSession
    
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    func retrieveImage(using urlString: String) async throws -> UIImage? {
        guard let url = URL(string: urlString) else {
            throw NetworkServiceError.unableToCreateURL
        }
        
        do {
            let (data, response) = try await urlSession.data(from: url)
            
            guard let httpURLResponse = response as? HTTPURLResponse,
                  httpURLResponse.statusCode == 200 else {
                throw NetworkServiceError.badResponse
            }
            
            guard let uiImage = UIImage(data: data) else {
                throw NetworkServiceError.unableToCreateImage
            }
            
            return uiImage
        } catch {
            throw NetworkServiceError.urlSessionError(error.localizedDescription)
        }
    }
    
    func fetchData<T: Decodable>(for urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkServiceError.unableToCreateURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpUrlResponse = response as? HTTPURLResponse,
              httpUrlResponse.statusCode == 200 else {
            throw NetworkServiceError.badResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkServiceError.unableToDecodeData
        }
    }
}

enum NetworkServiceError: Error {
    case unableToCreateURL
    case urlSessionError(String)
    case badResponse
    case unableToDecodeData
    case unableToCreateImage
}
