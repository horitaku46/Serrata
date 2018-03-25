//
//  ViewController.swift
//  Example
//
//  Created by Takuma Horiuchi on 2017/11/29.
//  Copyright © 2017年 Takuma Horiuchi. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    @IBOutlet weak private var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }

    @IBOutlet weak private var flowLayout: UICollectionViewFlowLayout! {
        didSet {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = 1
            flowLayout.minimumInteritemSpacing = 1
        }
    }

    private var images = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Images"

        for i in 0...29 {
            images.append(UIImage(named: "image\(i).jpg") ?? UIImage())
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension ViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? ImageCell else {
            return
        }

        let slideLeafs: [SlideLeaf] = images.enumerated().map { SlideLeaf(image: $0.1,
                                                                          title: "Image Title \($0.0)",
                                                                          caption: "Index is \($0.0)") }

        let slideImageViewController = SlideLeafViewController.make(leafs: slideLeafs,
                                                                    startIndex: indexPath.row,
                                                                    fromImageView: selectedCell.imageView)

        slideImageViewController.delegate = self
        present(slideImageViewController, animated: true, completion: nil)
    }
}

extension ViewController: SlideLeafViewControllerDelegate {
    
    func tapImageDetailView(slideLeaf: SlideLeaf, pageIndex: Int) {
        print(pageIndex)
        print(slideLeaf)

        let viewController = DetailViewController.make(detailTitle: slideLeaf.title)
        navigationController?.show(viewController, sender: nil)
    }

    func longPressImageView(slideLeafViewController: SlideLeafViewController, slideLeaf: SlideLeaf, pageIndex: Int) {
        print(slideLeafViewController)
        print(slideLeaf)
        print(pageIndex)
    }

    func slideLeafViewControllerDismissed(slideLeaf: SlideLeaf, pageIndex: Int) {
        print(slideLeaf)
        print(pageIndex)

        let indexPath = IndexPath(row: pageIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }
}

extension ViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.configure(image: images[indexPath.row])
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
