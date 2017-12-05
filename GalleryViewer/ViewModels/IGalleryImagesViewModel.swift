//
//  IGalleryImagesViewModel.swift
//  GalleryViewer
//
//  Created by Sergei Kultenko on 04/12/2017.
//  Copyright © 2017 Sergei Kultenko. All rights reserved.
//

import Foundation

protocol IGalleryImagesViewModel {
  var imagesCount: Int { get }
  func getImage(forIndex index:Int, withCompletionHanler completion: @escaping (_ image: GalleryImage?) -> Void )
  func loadAllImages()
  var completion: Double { get }
}
