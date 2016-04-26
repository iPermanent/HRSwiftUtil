//
//  NSString+extentions.swift
//  HRSwiftUtil
//
//  Created by ZhangHeng on 16/4/25.
//  Copyright © 2016年 ZhangHeng. All rights reserved.
//

import Foundation

extension String {
    func md5String()->String{
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen);
        
        CC_MD5(str!, strLen, result);
        
        let hash = NSMutableString();
        for i in 0 ..< digestLen {
            hash.appendFormat("x", result[i]);
        }
        result.destroy();
        
        return String(format: hash as String)
    }
    
    func base64String()->String{
        let data:NSData = (self.dataUsingEncoding(NSUTF8StringEncoding)?.base64EncodedDataWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength))!
        let string = NSString.init(data: data, encoding: NSUTF8StringEncoding)
        return String(string)
    }
}
