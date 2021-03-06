//
//  CollectionsViewController.swift
//  ImSplash
//
//  Created by Doan Minh Hoang on 4/21/20.
//  Copyright © 2020 Doan Minh Hoang. All rights reserved.
//

import UIKit

class CollectionsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    private var photoThumbSize: CGFloat = 0
    var photos: [Photo] = []
    private var filtedPhotos: [Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUI()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        Utilities.collectionView = self
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Utilities.collectionView = nil
    }
    
    private func loadUI() {
        if let layout = collectionView.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        collectionView.backgroundColor = .clear
        photoThumbSize = (view.frame.size.width - 60 - 10) / 2
    }
    
    func loadData() {
        filterPhotoForDownload()
        collectionView.reloadData()
    }
    
    private func getLocalImages() {
        let data = UserDefaults.standard.object(forKey: "localImages") as? NSData
        do {
            let imageArray = data != nil ? try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data! as Data) as? [Photo] : [Photo]()
            filtedPhotos.append(contentsOf: imageArray!)
        }
    }
    
    private func filterPhotoForDownload() {
        filtedPhotos = photos.filter { $0.isDownloading || $0.isFavorite }
        getLocalImages()
    }
    
    private func filterPhotoForFavorite() {
        filterPhotoForDownload()
        filtedPhotos = filtedPhotos.filter { $0.isFavorite }
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func downloadButtonClicked(_ sender: Any) {
        favoriteButton.setTitleColor(.black, for: .normal)
        downloadButton.setTitleColor(UIColor(hexString: "E12C1C"), for: .normal)
        filterPhotoForDownload()
        collectionView.reloadData()
    }
    
    @IBAction func favoriteButtonClicked(_ sender: Any) {
        favoriteButton.setTitleColor(UIColor(hexString: "E12C1C"), for: .normal)
        downloadButton.setTitleColor(.black, for: .normal)
        filterPhotoForFavorite()
        collectionView.reloadData()
    }
}

extension CollectionsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filtedPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UnsplashHomeCollectionViewCell", for: indexPath) as! UnsplashHomeCollectionViewCell
        cell.setupCellForDownload(photo: filtedPhotos[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: photoThumbSize, height: photoThumbSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "PhotoViewStoryboard", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "PhotoViewViewController") as! PhotoViewViewController
        vc.photo = filtedPhotos[indexPath.row]
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
}

extension CollectionsViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
        return filtedPhotos[indexPath.row].photoHeight
    }
}
