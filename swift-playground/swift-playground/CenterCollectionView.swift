//
//  CenterCollectionView.swift
//  Catchit
//
//  Created by viktor johansson on 25/05/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {
    
    var centerPoint : CGPoint {
        
        get {
            return CGPoint(x: self.center.x + self.contentOffset.x, y: self.center.y + self.contentOffset.y);
        }
    }
    
    var centerCellIndexPath: NSIndexPath? {
        
        if let centerIndexPath: NSIndexPath  = self.indexPathForItemAtPoint(self.centerPoint) {
            return centerIndexPath
        }
        return nil
    }
}