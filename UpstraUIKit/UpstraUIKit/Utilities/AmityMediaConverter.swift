//
//  AmityMediaConverter.swift
//  AmityUIKit
//
//  Created by Hamlet Kosakyan on 7/2/2565 BE.
//  Copyright © 2565 BE Amity. All rights reserved.
//

import Foundation
import ImageIO
import MobileCoreServices
import UIKit

class AmityMediaConverter {
    static func convertImage(fromPath path: String) -> URL? {
        let options = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceSubsampleFactor: 2
        ] as CFDictionary
        
        guard let url = URL(string: path), let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil), let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, options), let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [AnyHashable: Any] else { return nil }
        
        let uuid = UUID().uuidString
        let suffix = "\(uuid).png"
        
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else { return nil }
        
        directory.appendingPathComponent(suffix)
        guard let absoluteString = directory.absoluteString, let destinationURL = URL(string: "\(absoluteString)\(suffix)"), let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypePNG, 1, nil) else { return nil }
        
        CGImageDestinationAddImage(destination, cgImage, options)
        if CGImageDestinationFinalize(destination) {
            return destinationURL
        }
        
        return nil
    }
}

import AVFoundation

extension AmityMediaConverter {
    static func convertVideo(asset: AVAsset, completion: @escaping (_ responseURL: URL?) -> Void) {
        // Get the destination directory
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            print("Failed to get the documents directory.")
            completion(nil)
            return
        }
        
        // Create a unique file name
        let uuid = UUID().uuidString
        let destinationURL = directory.appendingPathComponent("\(uuid).mp4")
        
        // Define export preset and file type
        let preset = AVAssetExportPresetHighestQuality
        let outputFileType = AVFileType.mp4
        
        // Check compatibility of the export preset with the asset
        AVAssetExportSession.determineCompatibility(ofExportPreset: preset, with: asset, outputFileType: outputFileType) { isCompatible in
            guard isCompatible else {
                print("Export preset \(preset) is not compatible with the provided asset.")
                completion(nil)
                return
            }
            
            // Create and configure the export session
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: preset) else {
                print("Failed to create AVAssetExportSession.")
                completion(nil)
                return
            }
            
            // Configure HDR to SDR conversion if the asset is HDR
            if let videoTrack = asset.tracks(withMediaType: .video).first {
                let videoComposition = AVMutableVideoComposition(propertiesOf: asset)
                videoComposition.colorPrimaries = AVVideoColorPrimaries_ITU_R_709_2
                videoComposition.colorTransferFunction = AVVideoTransferFunction_ITU_R_709_2
                videoComposition.colorYCbCrMatrix = AVVideoYCbCrMatrix_ITU_R_709_2
                exportSession.videoComposition = videoComposition
            }
            
            exportSession.outputFileType = outputFileType
            exportSession.outputURL = destinationURL
            
            // Perform the export
            exportSession.exportAsynchronously {
                switch exportSession.status {
                case .completed:
                    print("Export completed successfully: \(destinationURL)")
                    completion(destinationURL)
                case .failed:
                    print("Export failed with error: \(exportSession.error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                case .cancelled:
                    print("Export was cancelled.")
                    completion(nil)
                default:
                    print("Export encountered an unexpected status: \(exportSession.status.rawValue)")
                    completion(nil)
                }
            }
        }
    }
    
    
}
