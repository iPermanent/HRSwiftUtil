//
//  HRRoundView.swift
//  HRSwiftUtil
//
//  Created by ZhangHeng on 16/5/10.
//  Copyright © 2016年 ZhangHeng. All rights reserved.
//

import UIKit

enum HRRoundType {
    case top
    case bottom
    case left
    case right
    case all
    case none
}

class HRRoundView: UIView {
    private var _roundType:HRRoundType = HRRoundType.none
    internal var roundType: HRRoundType {
        set{
            self._roundType = newValue
            self.layer.mask = nil
            var corners:UIRectCorner?
            switch _roundType {
            case .left:
                corners = [UIRectCorner.BottomLeft,UIRectCorner.TopLeft]
            case .top:
                corners = [UIRectCorner.TopLeft,UIRectCorner.TopRight]
            case .bottom:
                corners = [UIRectCorner.BottomLeft,UIRectCorner.BottomRight]
            case .right:
                corners = [UIRectCorner.BottomRight,UIRectCorner.TopRight]
            case .all: 
                corners = UIRectCorner.AllCorners
            case .none: 
                corners = UIRectCorner(rawValue: UIRectCorner.BottomRight.rawValue & UIRectCorner.TopLeft.rawValue)
            }
            
            let maskPath:UIBezierPath = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: corners!, cornerRadii:CGSizeMake(10.0,10.0))
            let maskLayer:CAShapeLayer = CAShapeLayer.init()
            maskLayer.frame = self.bounds
            maskLayer.path = maskPath.CGPath
            self.layer.mask = maskLayer
            
        }get{
            return _roundType
        }
    }

}
