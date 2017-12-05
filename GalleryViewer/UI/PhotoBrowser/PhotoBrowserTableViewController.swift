//
//  PhotoBrowserTableViewController.swift
//  GalleryViewer
//
//  Created by Sergei Kultenko on 04/12/2017.
//  Copyright © 2017 Sergei Kultenko. All rights reserved.
//

import UIKit
import Photos

class PhotoBrowserTableViewController: UITableViewController {
  
  // MARK: - Vars
  var hudView: UIView?
  var frameView: UIView?
  var timer: Timer?
  
  @IBOutlet weak var progressView: UIProgressView?
  
  var viewModel: IGalleryImagesViewModel? {
    didSet {
      DispatchQueue.main.async {
        self.loadAllImages()
        self.showHUD()
      }
    }
  }
  
  // MARK: - View Controller Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(PhotoBrowserTableViewController.viewModelNotificationReceived(_:)),
                                           name: ImageGalleryNotifications.ImageGalleryUpdated.notificationName,
                                           object: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Notification Handlers
  @objc func viewModelNotificationReceived(_ notification: Notification) {
    if notification.name == ImageGalleryNotifications.ImageGalleryUpdated.notificationName {
      removeHUD()
      tableView.reloadData()
    }
  }

  // MARK: - Supporting functions
  func showHUD() {
    let viewToShowOn = UIApplication.shared.keyWindow! //self.view
    
    hudView = UIView(frame: viewToShowOn.frame)
    hudView?.backgroundColor = UIColor(white: 0.61, alpha: 0.7)
    viewToShowOn.addSubview(hudView!)

    frameView = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
    frameView!.center = viewToShowOn.center
    frameView!.backgroundColor = UIColor.white
    frameView!.layer.cornerRadius = 10
    frameView!.clipsToBounds = true
    viewToShowOn.addSubview(frameView!)
    
    if let nibView = Bundle.main.loadNibNamed("LoadingHUDView", owner: self, options: nil)?[0] as? UIView {
      nibView.frame = frameView!.bounds
      frameView!.addSubview(nibView)
    }
    
    timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(PhotoBrowserTableViewController.updateHUD), userInfo: nil, repeats: true)
  }
  
  @objc func updateHUD() {
    self.progressView?.progress = Float(viewModel?.completion ?? 0)
  }

  func removeHUD() {
    timer?.invalidate()
    timer = nil
    UIView.animate(withDuration: 0.7, delay: 0, options: .curveLinear, animations: {
      self.frameView?.alpha = 0
      self.hudView?.alpha = 0
    }) { (_) in
      self.frameView?.removeFromSuperview()
      self.frameView = nil
      self.hudView?.removeFromSuperview()
      self.hudView = nil
    }
  }
  
  func loadAllImages() {
    if PHPhotoLibrary.authorizationStatus() != .authorized {
      PHPhotoLibrary.requestAuthorization({ [weak self] (status) in
        DispatchQueue.main.async {
          if PHPhotoLibrary.authorizationStatus() != .authorized {
            self?.removeHUD()
            self?.showErrorAlert(withMessage: "The App needs access to photo library")
          } else {
            self?.viewModel?.loadAllImages()
          }
        }
      })
    } else {
      viewModel?.loadAllImages()
    }
  }

  func showErrorAlert(withMessage message: String) {
    let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    alertView.addAction(UIAlertAction(title: "OK", style: .default))
    self.present(alertView, animated: true)
  }

  
  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel?.imagesCount ?? 0
  }
  
  let reuseIdentifier = "PhotoTableViewCell"
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
    
    guard let photoCell = cell as? PhotoTableViewCell else { return cell }

    photoCell.photoView?.image = nil
    photoCell.fileNameLabel.text = ""
    photoCell.fileSizeLabel.text = ""
    photoCell.fileHashLabel.text = ""
    
    photoCell.tag = indexPath.row
    viewModel?.getImage(forIndex: indexPath.row, withCompletionHanler: { (result) in
      DispatchQueue.main.async {
        guard let galleryImage = result, photoCell.tag == indexPath.row else { return }
        photoCell.photoView?.image = galleryImage.image
        photoCell.fileNameLabel.text = galleryImage.fileName
        photoCell.fileSizeLabel.text = String(format: "%.0f", galleryImage.fileSize)
        photoCell.fileHashLabel.text = galleryImage.fileHash
      }
    })
    
    return cell
  }
}
