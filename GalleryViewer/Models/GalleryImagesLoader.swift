//
//  GalleryImagesLoader.swift
//  GalleryViewer
//
//  Created by Sergei Kultenko on 04/12/2017.
//  Copyright © 2017 Sergei Kultenko. All rights reserved.
//

import Foundation
import Photos

class GalleryImagesLoader {
  
  var loadingPercentage: String {
    guard let toLoad = imagesToLoad else {
      return "100%"
    }
    let percent = Double(imagesLoaded) / Double(toLoad) * 100
    return String(format: "%.0f%", percent)
  }
  
  var completion:Double {
    guard let toLoad = imagesToLoad else {
      return 0
    }
    return Double(imagesLoaded) / Double(toLoad)
  }
  
  private var imagesToLoad: Int?
  private var imagesLoaded: Int = 0

  func getImages(withCompletionHanler completion: @escaping (_ success: Bool ) -> Void) {
    DispatchQueue.global().async {
      let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
      var images = [PHAsset]()
      assets.enumerateObjects({ (object, count, stop) in
        images.append(object)
      })

      guard let filesDirectory = self.directoryToSaveFiles() else {
        completion(false)
        return
      }
      let imageManager = PHImageManager.default()
      let options = PHImageRequestOptions()
      options.version = .original
      options.isSynchronous = false

      self.imagesToLoad = images.count
      //I dont want to load too much
      if self.imagesToLoad! > 100 {
        self.imagesToLoad = 100
      }
      let group = DispatchGroup()
      for (index, image) in images.enumerated() {
        if index > self.imagesToLoad! {
          break
        }
        group.enter()
        imageManager.requestImageData(for: image, options: options, resultHandler: { (data, str, _, _) in
          let fileName = (filesDirectory as NSString).appendingPathComponent(String(format: "/Image%d", index))
          FileManager.default.createFile(atPath: fileName, contents: data, attributes: nil)
          self.imagesLoaded +=  1
          group.leave()
        })
      }
      group.notify(queue: DispatchQueue.main, execute: {
        completion(true)
      })
    }
  }
  
  private func removeAllFiles(inDirectory directory: String) {
    let fileManager = FileManager.default
    do {
      let filePaths = try fileManager.contentsOfDirectory(atPath: directory)
      for filePath in filePaths {
        try fileManager.removeItem(atPath: directory + filePath)
      }
    } catch {
      print("Could not clear temp folder: \(error)")
    }
  }
  
  func directoryToSaveFiles() -> String? {
    guard let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last else {
      return nil
    }
    
    let path = (documentsDirectory as NSString).appendingPathComponent("imageFiles")
    let fileManger = FileManager.default
    var isDir : ObjCBool = true
    if !fileManger.fileExists(atPath: path, isDirectory: &isDir) {
      // Need to create dir
      try? fileManger.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    } else {
      if !isDir.boolValue {
        return nil
      }
    }
    return path
  }
  
}
