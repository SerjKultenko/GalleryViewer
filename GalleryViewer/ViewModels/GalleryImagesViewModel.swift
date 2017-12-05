//
//  GalleryImagesViewModel.swift
//  GalleryViewer
//
//  Created by Sergei Kultenko on 04/12/2017.
//  Copyright © 2017 Sergei Kultenko. All rights reserved.
//

import Foundation
//import Photos
import UIKit

class GalleryImagesViewModel: IGalleryImagesViewModel {

  var scale: CGFloat = 1
  var thumbnailWidth: CGFloat = 100
  
  private var loader: GalleryImagesLoader?
  
  var completion: Double {
    return loader?.completion ?? 0
  }
  
  private var imagesPaths: [String] = []
  var imagesCount: Int {
   return imagesPaths.count
  }

  func getImage(forIndex index:Int, withCompletionHanler completion: @escaping (_ image: GalleryImage?) -> Void ) {
    guard index < imagesCount else {
      completion(nil)
      return
    }
    
    DispatchQueue.global().async { [weak self] in
      guard let strongSelf = self else {
        return
      }
      
      let fileName = strongSelf.imagesPaths[index]
      
      let fileAttributes = try? FileManager.default.attributesOfItem(atPath: fileName)
      let fileSize = (fileAttributes?[FileAttributeKey.size] as? NSNumber)?.doubleValue
      
      guard fileSize != nil, let imageData = NSData(contentsOfFile: fileName) else {
        completion(nil)
        return
      }
      
      let fileHash = (imageData as Data).md5.description
      
      let width = strongSelf.thumbnailWidth * strongSelf.scale
      let options = [
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceThumbnailMaxPixelSize: width] as CFDictionary
      let source = CGImageSourceCreateWithData(imageData, nil)!
      let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options)!
      let thumbnail = UIImage(cgImage: imageReference)
      
      let imageObject = GalleryImage(image: thumbnail, fileName: (fileName as NSString).lastPathComponent, fileSize: fileSize!, fileHash: fileHash)
      completion(imageObject)
    }
  }
  
  func loadAllImages() {
    loader = GalleryImagesLoader()
    let directoryToSaveFiles = loader!.directoryToSaveFiles()
    loader!.getImages { [weak self] (success) in
      guard let strongSelf = self, let imagesDirectory = directoryToSaveFiles else { return }

      let enumerator = FileManager.default.enumerator(atPath: imagesDirectory)
      
      while let element = enumerator?.nextObject() as? String {
        let fullFilePath = (imagesDirectory as NSString).appendingPathComponent(element)
        strongSelf.imagesPaths.append(fullFilePath)
      }
      
      DispatchQueue.main.async {
        NotificationCenter.default.post(
          name: ImageGalleryNotifications.ImageGalleryUpdated.notificationName,
          object: nil
        )
      }
    }
  }

}
