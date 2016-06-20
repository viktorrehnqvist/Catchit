//
//  ActivityIndicatorCollectionView.swift
//  Catchit
//
//  Created by viktor johansson on 09/06/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {
    
    func loadIndicatorBottom() {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityIndicator.frame = CGRect(x: self.bounds.midX, y: self.contentSize.height + 10, width: 0, height: 0)
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = false
        self.addSubview(activityIndicator)
    }
    
    func loadIndicatorSearch() {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityIndicator.frame = CGRect(x: self.bounds.midX, y: self.contentSize.height, width: 0, height: 0)
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = false
        self.removeIndicators()
        self.addSubview(activityIndicator)
    }
    
    func loadIndicatorTop() {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityIndicator.frame = CGRect(x: self.bounds.midX, y: -20, width: 0, height: 0)
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = false
        self.addSubview(activityIndicator)
    }
    
    func loadIndicatorMid(screenSize: CGRect, style: UIActivityIndicatorViewStyle) {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: style)
        activityIndicator.frame = CGRect(x: screenSize.midX, y: screenSize.midY - 80, width: 0, height: 0)
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = false
        self.addSubview(activityIndicator)
    }
    
    func loadIndicatorMidWithHeader(screenSize: CGRect) {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityIndicator.frame = CGRect(x: screenSize.midX, y: self.contentSize.height + 20, width: 0, height: 0)
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = false
        self.addSubview(activityIndicator)
    }
    
    func removeIndicators() {
        let activityIndicators = self.subviews.filter{$0 is UIActivityIndicatorView}
        for a in activityIndicators {
            a.removeFromSuperview()
        }
    }
    
}