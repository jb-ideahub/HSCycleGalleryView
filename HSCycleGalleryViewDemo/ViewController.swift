//
//  ViewController.swift
//  HSCycleGalleryViewDemo
//
//  Created by Hanson on 2018/1/18.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit
import HSCycleGalleryView

class ViewController: UIViewController {

    let colors: [UIColor] = [.cyan, .blue, .green, .red]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pager = HSCycleGalleryView(frame: CGRect(x: 0, y: 40, width: UIScreen.main.bounds.width, height: 200))
        pager.isZoomEnabled = false
        pager.itemSpacing = 8
        pager.autoScrollInterval = 0
        pager.register(cellClass: TestCollectionViewCell.self, forCellReuseIdentifier: "TestCollectionViewCell")
        pager.delegate = self
        self.view.addSubview(pager)
        pager.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func test(_ sender: Any) {
        let vc = TestViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ViewController: HSCycleGalleryViewDelegate {
    func changePageControl(currentIndex: Int) {
        print("PAGE: ", currentIndex)
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

