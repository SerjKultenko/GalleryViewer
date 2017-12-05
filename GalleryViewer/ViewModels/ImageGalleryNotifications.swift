//
//  ImageGalleryNotifications.swift
//  GalleryViewer
//
//  Created by Sergei Kultenko on 04/12/2017.
//  Copyright © 2017 Sergei Kultenko. All rights reserved.
//

import Foundation

enum ImageGalleryNotifications: String {
  case ImageGalleryUpdated = "ImageGalleryUpdated"
  
  var notificationName: NSNotification.Name {
    return NSNotification.Name(self.rawValue)
  }
}
