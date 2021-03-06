//
//  CustomCollectionView.swift
//  FocusOn
//
//  Created by Rafal Padberg on 02.05.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

class CustomCollectionView: UICollectionView {
    
    // MARK:- Public Properties
    
    var customDelegate: CustomCollectionViewDelegate?
    
    // MARK:- Private Properties
    
    private var highlightedCell = 0
    private var type: CellType!

    private var data: [String] = []
    private var isDataAvailable: [Bool] = []
    
    // MARK:- Initializers
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUp()
    }
    
    // MARK:- View Layout Methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setContentOffset(.zero, animated: false)
    }
    
    // MARK:- Public Methods
    
    func config(type: CellType) {
        
        self.type = type
    }
    
    func insertData(data: [String], isDataAvailable: [Bool]) {
        
        self.data = data
        self.isDataAvailable = isDataAvailable
        reloadData()
    }
    
    // MARK:- Private Methods
    
    private func setUp() {
        
        delegate = self
        dataSource = self
        
        register(UINib(nibName: "CustomCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CustomCell")
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            
            layout.itemSize = CGSize(width: 56, height: 20)
            layout.sectionInset = UIEdgeInsets(top: 10, left: 1, bottom: 10, right: 1)
            layout.minimumLineSpacing = 10
        }
    }
    
    private func highlightCell(withIndex index: Int) {
        
        highlightedCell = index
        reloadData()
    }
}

// MARK:- UICollectionViewDelegate Methods

extension CustomCollectionView: UICollectionViewDelegate {
    
    // todo: Case when switching from december 2018 to december 2019 it should be impossible or change to whole year
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item
        if index != highlightedCell && isDataAvailable[index] == true {
            
            highlightCell(withIndex: indexPath.item)
            let number = type == .monthsCell ? index : Int(data[index])!
            customDelegate?.cellWasSelected(withIndex: number, cellType: type)
        }
    }
}

// MARK:- UICollectionViewDataSource Methods

extension CustomCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCollectionViewCell
        
        cell.setTitile(to: data[indexPath.item])
        let index = indexPath.item
        
        if type == .monthsCell && isDataAvailable[highlightedCell] == false {
            highlightedCell = 0
            customDelegate?.cellWasSelected(withIndex: 0, cellType: .monthsCell)
        }
        
        if index == highlightedCell {
            cell.highlightCell()
        } else {
            if isDataAvailable[index] {
                cell.clearCell()
            } else {
                cell.setUnavailable()
            }
        }
        return cell
    }
}
