//
//  UIImage+extensions.swift
//  HRSwiftUtil
//
//  Created by ZhangHeng on 16/4/26.
//  Copyright © 2016年 ZhangHeng. All rights reserved.
//

import UIKit

extension UIImage{
    func compress(value:CGFloat) -> UIImage{
        let size = CGSizeMake(self.size.width*value, self.size.height*value)
        let imgData = UIImageJPEGRepresentation(self, value)
        let image = UIImage.init(data: imgData!)
        
        return self.imageWithSize(image!, size: size)
    }
    
    //get an image size about 100kb - 200kb
    func compressedImageForUpload()->UIImage{
        var data:NSData! = UIImageJPEGRepresentation(self, 1)
        let compressQuality = 153600.0/Double(data.length)
        if compressQuality < 1{
            data = UIImageJPEGRepresentation(self, CGFloat(compressQuality))
        }
        
        let screenWidth = 1080
        let imageWidth = min(self.size.width, 1080)
        var ratio = imageWidth/CGFloat(screenWidth)
        if ratio >= 1{
            ratio = 1.0
        }
        let image = UIImage.init(data: data)
        let newSize = CGSizeMake((image?.size.width)!/ratio, (image?.size.height)!/ratio)
        return self.imageWithSize(image!, size: newSize)
    }

    func resizeImage(size:CGSize) -> UIImage {
        let orSize = self.size
        let compressValue = size.width/orSize.width
        var data = UIImageJPEGRepresentation(self, 1)
        if compressValue < 1{
            data = UIImageJPEGRepresentation(self, compressValue)
        }
        let retImg = UIImage.init(data: data!)
        
        return self.imageWithSize(retImg!, size: size)
    }
    
    private func imageWithSize(image:UIImage,size:CGSize)->UIImage{
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
