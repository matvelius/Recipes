//
//  FileStorageService.swift
//  RecipeApp
//
//  Created by Matvey Kostukovsky on 10/29/24.
//

import UIKit
import os

protocol FileStorageServiceProtocol {
    var folderURL: URL? { get }
    
    func save(_ image: UIImage, for key: String) throws
    func retrieveImage(for key: String) throws -> UIImage?
    func removeImage(for key: String) throws
}

public final class FileStorageService: FileStorageServiceProtocol {
    public static let shared = FileStorageService()
    
    private let logger = Logger(subsystem: "FileStorageService", category: "data")
    
    private let fileManager = FileManager.default
    
    internal var folderURL: URL? {
        fileManager
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first
    }
    
    func save(_ image: UIImage, for key: String) throws {
        guard !key.isEmpty else {
            throw FileStorageServiceError.keyIsAnEmptyString
        }
        
        guard let pathURL = folderURL?.appendingPathComponent(key + ".cache") else {
            throw FileStorageServiceError.unableToCreateImagePath
        }
        
        guard let jpgImageData = image.jpegData(compressionQuality: 1.0) else {
            throw FileStorageServiceError.unableToCreateImageData
        }
        
        do {
            try jpgImageData.write(to: pathURL, options: [.atomic])
            logger.info("Image file for key \(key) saved at path \(pathURL.path)")
        } catch {
            throw FileStorageServiceError.unableToWriteToDisk(error.localizedDescription)
        }
    }
    
    func retrieveImage(for key: String) throws -> UIImage? {
        guard !key.isEmpty else {
            throw FileStorageServiceError.keyIsAnEmptyString
        }
        
        guard let pathURL = folderURL?.appendingPathComponent(key + ".cache") else {
            throw FileStorageServiceError.unableToCreateImagePath
        }
        
        guard fileManager.fileExists(atPath: pathURL.path) else {
            logger.info("File for key \(key) does not exist at path \(pathURL.path)")
            return nil
        }
        
        return UIImage(contentsOfFile: pathURL.path)
    }
    
    func removeImage(for key: String) throws {
        guard !key.isEmpty else {
            throw FileStorageServiceError.keyIsAnEmptyString
        }
        
        guard let pathURL = folderURL?.appendingPathComponent(key + ".cache") else {
            throw FileStorageServiceError.unableToCreateImagePath
        }
        
        guard fileManager.fileExists(atPath: pathURL.path) else {
            logger.info("File for key \(key) does not exist at path \(pathURL.path)")
            return
        }
        
        do {
            try fileManager.removeItem(at: pathURL)
        } catch  {
            throw FileStorageServiceError.unableToRemoveImage(error.localizedDescription)
        }
    }
}

public enum FileStorageServiceError: Error {
    case keyIsAnEmptyString
    case unableToCreateImagePath
    case unableToCreateImageData
    case unableToWriteToDisk(String)
    case unableToRemoveImage(String)
}
