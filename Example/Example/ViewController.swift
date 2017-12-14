//
//  ViewController.swift
//  SerrataSample
//
//  Created by Takuma Horiuchi on 2017/11/29.
//  Copyright © 2017年 Takuma Horiuchi. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout! {
        didSet {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = 1
            flowLayout.minimumInteritemSpacing = 1
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    private var imageUrls = ["https://cdn.mdpr.jp/photo/images/5b/66d/w700c-ez_09bb9af9e97b5ca14c8c95c7dc3ae2b5a3cb98de9880c22f.jpg",
                             "https://cdn.mdpr.jp/photo/images/22/3b3/w700c-ez_c473f7e2107a4715cb4101872055751bacc3e1ce73ecac60.jpg",
                             "https://cdn.mdpr.jp/photo/images/c6/ac7/w700c-ez_2f39af1f842d8557466fa56a9c267979d912cafe81f43e9c.jpg",
                             "https://cdn.mdpr.jp/photo/images/98/84c/w700c-ez_ab8f59492a6de185f4a3f3a56caca47e271d02651661fcd3.jpg",
                             "https://cdn.mdpr.jp/photo/images/e0/c38/w700c-ez_9ee6a6569ac6222b51fd74ea0327a1de12b118561b97afc0.jpg",
                             "https://cdn.mdpr.jp/photo/images/07/080/w700c-ez_92ae844335f62db9771e44987cdfc32cc893080d3b001e75.jpg",
                             "https://cdn.mdpr.jp/photo/images/47/6d3/w700c-ez_45ac2a4fca58d3f09907e8abe3b6f6d7caae18b4400e76d5.jpg",
                             "https://cdn.mdpr.jp/photo/images/d0/00a/w700c-ez_dca05db485f1368f5fe37dcb409b72a4ccaad7209304a885.jpg",
                             "https://cdn.mdpr.jp/photo/images/09/ac9/w700c-ez_5b25e35d0226e5b020142c1409a163cc6ef0ced55724f9f2.jpg"]
}

extension ViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? ImageCell else {
            return
        }
        var slideLeafs = [SlideLeaf]()
        for index in 0..<imageUrls.count {
//            let leaf = SlideLeaf(image: UIImage(named: "keyaki\(index).jpg"),
//                                 title: "ぺーちゃん\(index)号",
//                                 caption: "君のハートにレボ⭐️リューション \(index)回目")
//            let leaf = SlideLeaf(urlStr: imageUrls[index])
            let leaf = SlideLeaf(urlStr: imageUrls[index],
                                 title: "ぺーちゃん\(index)号",
                                 caption: "君のハートにレボ⭐️リューション \(index)回目 君のハートにレボ⭐️リューション \(index)回目　君のハートにレボ⭐️リューション \(index)回目　君のハートにレボ⭐️リューション \(index)回目　君のハートにレボ⭐️リューション \(index)回目　君のハートにレボ⭐️リューション \(index)回目　君のハートにレボ⭐️リューション \(index)回目　君のハートにレボ⭐️リューション \(index)回目")
            slideLeafs.append(leaf)
        }
        let slideImageViewController = SlideLeafViewController.make(leafs: slideLeafs,
                                                                    startIndex: indexPath.row,
                                                                    fromImageView: selectedCell.imageView)
        slideImageViewController.delegate = self
        present(slideImageViewController, animated: true, completion: nil)
    }
}

extension ViewController: SlideLeafViewControllerDelegate {

    func longPressImageView(slideLeafViewController: SlideLeafViewController, slideLeaf: SlideLeaf, pageIndex: Int) {
        print(slideLeafViewController)
        print(slideLeaf)
        print(pageIndex)
    }
    
    func tapImageDetailView(slideLeaf: SlideLeaf, pageIndex: Int) {
        print(pageIndex)
        print(slideLeaf)
        let viewController = WebViewController.make()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension ViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.configure(urlStr: imageUrls[indexPath.row])
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let isPortraint = UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation)
        let itemSide: CGFloat = isPortraint ? (collectionView.bounds.width - 1) / 2 : (collectionView.bounds.width - 2) / 3
        return CGSize(width: itemSide, height: itemSide)
    }
}
