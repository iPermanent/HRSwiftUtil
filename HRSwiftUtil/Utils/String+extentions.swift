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
    
    func sha1()->String{
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        var digest = [UInt8](count:Int(CC_SHA1_DIGEST_LENGTH), repeatedValue: 0)
        CC_SHA1(data.bytes, CC_LONG(data.length), &digest)
        let output = NSMutableString(capacity: Int(CC_SHA1_DIGEST_LENGTH))
        for byte in digest {
            output.appendFormat("%02x", byte)
        }
        return output as String
    }
}
