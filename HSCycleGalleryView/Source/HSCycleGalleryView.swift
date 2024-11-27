//
//  HSCycleGalleryView.swift
//  HSCycleGalleryView
//
//  Created by Hanson on 2018/1/16.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit

@objc public protocol HSCycleGalleryViewDelegate: AnyObject {

	func numberOfItemInCycleGalleryView(_ cycleGalleryView: HSCycleGalleryView) -> Int
	func changePageControl(currentIndex: Int)
	func cycleGalleryView(_ cycleGalleryView: HSCycleGalleryView, cellForItemAtIndex index: Int) -> UICollectionViewCell

	@objc optional func cycleGalleryView(_ cycleGalleryView: HSCycleGalleryView, didSelectItemCell cell: UICollectionViewCell, at Index: Int)
}

public class HSCycleGalleryView: UIView {

	public weak var delegate: HSCycleGalleryViewDelegate?

	/// if set to 0, the gallery view will not auto scroll
	public var autoScrollInterval: Double = 3
    
    public var itemSpacing: CGFloat = 20 {
        didSet {
            customLayout.interItemSpacing = itemSpacing
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    public var isZoomEnabled: Bool = true {
        didSet {
            customLayout.isZoomEnabled = isZoomEnabled
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }

	public var contentBackgroundColor = UIColor.white {
		didSet {
			collectionView.backgroundColor = contentBackgroundColor
		}
	}
    
    public var itemWidth = 200.0 {
            didSet {
                customLayout.itemWidth = itemWidth
                collectionView.collectionViewLayout.invalidateLayout()
            }
        }

        public var itemHeight = 200.0 {
            didSet {
                customLayout.itemHeight = itemHeight
                collectionView.collectionViewLayout.invalidateLayout()
            }
        }

	private var collectionView: UICollectionView!
    private var customLayout: HSCycleGalleryViewLayout!
	private let groupCount = 200
	private var indexArr = [Int]()
	private var dataNum: Int = 0

	private var timer: Timer?
	private var currentIndexPath: IndexPath!


	// MARK: - Initialization

	override public init(frame: CGRect) {
		super.init(frame: frame)
        customLayout = HSCycleGalleryViewLayout()
                customLayout.itemWidth = itemWidth
                customLayout.itemHeight = itemHeight
		collectionView = UICollectionView(frame: frame, collectionViewLayout: customLayout)
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.showsVerticalScrollIndicator = false
		collectionView.backgroundColor = contentBackgroundColor
		collectionView.delegate = self
		collectionView.dataSource = self

		self.addSubview(collectionView)
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override public func willMove(toSuperview newSuperview: UIView?) {
		if newSuperview != nil {
			removeTimer()
			addTimer()
		} else {
			removeTimer()
		}
	}
}


// MARK: - Public Function

extension HSCycleGalleryView {

    public func reloadData() {
        guard let dataNum = delegate?.numberOfItemInCycleGalleryView(self) else { return }
        self.dataNum = dataNum
        indexArr = Array(0..<dataNum) // Use only the actual data indices
        collectionView.reloadData()
        
        // Safely handle cases with fewer than 2 items
        if dataNum == 1 {
            // Focus on the first (and only) item
            currentIndexPath = IndexPath(item: 0, section: 0)
        } else {
            // Focus on the 2nd item
            currentIndexPath = IndexPath(item: 1, section: 0)
        }
        
        collectionView.scrollToItem(at: currentIndexPath, at: .centeredHorizontally, animated: false)
    }

	public func register(cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
		self.collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
	}

	public func register(nib: UINib?, forCellReuseIdentifier identifier: String) {
		self.collectionView.register(nib, forCellWithReuseIdentifier: identifier)
	}

	public func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)

		return cell
	}
}


// MARK: - Private Function

extension HSCycleGalleryView {

	func removeTimer() {
		self.timer?.invalidate()
		timer = nil
	}

	func addTimer() {
		guard autoScrollInterval > 0 else { return }
		guard timer == nil else { return }
		timer = Timer(timeInterval: autoScrollInterval, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: true)
		RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
	}

    @objc func autoScroll() {
        guard self.superview != nil, self.window != nil else { return }
        guard dataNum > 1 else { return } // Stop auto-scroll if only 1 item exists
        
        self.scrollToNextIndex()
    }

    private func scrollToNextIndex() {
        guard dataNum > 1 else { return } // Stop auto-scroll if only 1 item exists
        
        var currentIndex = currentIndexPath.row
        if (currentIndex + 1) >= dataNum {
            return // Stop scrolling beyond the last item
        }
        
        let nextIndex = currentIndex + 1
        collectionView.scrollToItem(at: IndexPath(item: nextIndex, section: 0), at: .centeredHorizontally, animated: true)
        currentIndexPath = IndexPath(item: nextIndex, section: 0)
        
        delegate?.changePageControl(currentIndex: nextIndex)
    }
}

extension HSCycleGalleryView: UICollectionViewDelegate, UICollectionViewDataSource {

	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return indexArr.count
	}

	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard indexArr.count > 0 else { return UICollectionViewCell() }
		let index = indexArr[indexPath.row]
		let dataIndex = index % dataNum

		return self.delegate?.cycleGalleryView(self, cellForItemAtIndex: dataIndex) ?? UICollectionViewCell()
	}

	public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let index = indexArr[indexPath.row]
		let dataIndex = index % dataNum
		let cell = collectionView.cellForItem(at: indexPath) ?? UICollectionViewCell()
        
		delegate?.cycleGalleryView?(self, didSelectItemCell: cell, at: dataIndex)
	}

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard dataNum > 0 else { return }
        
        let pointInView = self.convert(collectionView.center, to: collectionView)
        let indexPathNow = collectionView.indexPathForItem(at: pointInView)
        let index = indexPathNow?.row ?? 0
        
        currentIndexPath = IndexPath(item: index, section: 0)
        delegate?.changePageControl(currentIndex: index)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            // Calculate the index based on the content offset and item size
            let itemWidth = customLayout.itemWidth
            let offset = scrollView.contentOffset.x + (scrollView.frame.width / 2)
            let index = Int(offset / itemWidth) % dataNum

            delegate?.changePageControl(currentIndex: index)
        }

	public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		addTimer()
	}

	public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		removeTimer()
	}
}

