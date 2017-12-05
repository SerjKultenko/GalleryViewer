//
//  StartViewController.swift
//  GalleryViewer
//
//  Created by Sergei Kultenko on 04/12/2017.
//  Copyright © 2017 Sergei Kultenko. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let vc = segue.destination as? PhotoBrowserTableViewController {
      let viewModel = GalleryImagesViewModel()
      vc.viewModel = viewModel
    }
  }
}
