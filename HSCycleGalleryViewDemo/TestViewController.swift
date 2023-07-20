//
//  TestViewController.swift
//  HSCycleGalleryViewDemo
//
//  Created by Hanson on 2021/2/8.
//  Copyright © 2021 HansonStudio. All rights reserved.
//

import UIKit
import HSCycleGalleryView

class TestViewController: UIViewController {

    let colors: [UIColor] = [.cyan, .blue, .green, .red]
    
    private var cycleGalleryView: HSCycleGalleryView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        cycleGalleryView = HSCycleGalleryView(frame: CGRect(x: 0, y: 40, width: UIScreen.main.bounds.width, height: 200))
        cycleGalleryView.itemWidth = 60 // Set the desired item width here
        cycleGalleryView.itemHeight = 600 // Set t
        cycleGalleryView.contentBackgroundColor = UIColor.lightGray
        cycleGalleryView.autoScrollInterval = 2
        cycleGalleryView.register(cellClass: TestCollectionViewCell.self, forCellReuseIdentifier: "TestCollectionViewCell")
        cycleGalleryView.delegate = self
        view.addSubview(cycleGalleryView)
        cycleGalleryView.reloadData()
    }
    
    deinit {
        print("--- TestViewController Deinit ---")
    }

}


extension TestViewController: HSCycleGalleryViewDelegate {
    func changePageControl(currentIndex: Int) {
        //
    }
    
    func numberOfItemInCycleGalleryView(_ cycleGalleryView: HSCycleGalleryView) -> Int {
        return colors.count
    }
    
    func cycleGalleryView(_ cycleGalleryView: HSCycleGalleryView, cellForItemAtIndex index: Int) -> UICollectionViewCell {
        let cell = cycleGalleryView.dequeueReusableCell(withIdentifier: "TestCollectionViewCell", for: IndexPath(item: index, section: 0)) as! TestCollectionViewCell
        cell.backgroundColor = colors[index]
        cell.testLabel.text = "\(index)"
        return cell
    }
}

