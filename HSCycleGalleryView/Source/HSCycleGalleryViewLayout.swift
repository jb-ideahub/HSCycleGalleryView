//
//  HSCycleGalleryViewLayout.swift
//  HSCycleGalleryView
//
//  Created by Hanson on 2018/1/16.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit

class HSCycleGalleryViewLayout: UICollectionViewFlowLayout {
    
    var itemWidth: CGFloat = 290
    var itemHeight: CGFloat = 133
    var isZoomEnabled: Bool = true
    
    var interItemSpacing: CGFloat = 20  // Horizontal spacing between items
    
    override func prepare() {
        super.prepare()
        
        self.itemSize = CGSize(width: itemWidth, height: itemHeight)
        self.scrollDirection = .horizontal
        
        // Set only the item spacing
        self.minimumInteritemSpacing = interItemSpacing
        
        // Adjust section insets (optional)
        let left = (self.collectionView!.bounds.width - itemWidth) / 2
        let top = (self.collectionView!.bounds.height - itemHeight) / 2
        self.sectionInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let array = super.layoutAttributesForElements(in: rect)
        let visiableRect = CGRect(x: self.collectionView!.contentOffset.x,
                                  y: self.collectionView!.contentOffset.y,
                                  width: self.collectionView!.frame.width,
                                  height: self.collectionView!.frame.height)
        
        let centerX = self.collectionView!.contentOffset.x + self.collectionView!.bounds.width / 2
        
        for attributes in array! {
            if !visiableRect.intersects(attributes.frame) { continue }
            
            // Only apply scaling if zoom is enabled
            if isZoomEnabled {
                let offsetCenterX = abs(attributes.center.x - centerX)
                let scale = max(1 - offsetCenterX / self.collectionView!.bounds.width * 0.4, 0.8)
                attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
        
        return array
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let lastRect = CGRect(x: proposedContentOffset.x, y: proposedContentOffset.y,
                              width: self.collectionView!.bounds.width,
                              height: self.collectionView!.bounds.height)
        let centerX = proposedContentOffset.x + self.collectionView!.bounds.width * 0.5;
        let array = self.layoutAttributesForElements(in: lastRect)
        
        var adjustOffsetX = CGFloat(MAXFLOAT);
        for attri in array! {
            let deviation = attri.center.x - centerX
            if abs(deviation) < abs(adjustOffsetX) {
                adjustOffsetX = deviation
            }
        }
        return CGPoint(x: proposedContentOffset.x + adjustOffsetX, y: proposedContentOffset.y)
    }
}
