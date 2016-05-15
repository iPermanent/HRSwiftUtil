//
//  HRVideoUtil.swift
//  HRSwiftUtil
//
//  Created by ZhangHeng on 16/5/11.
//  Copyright © 2016年 ZhangHeng. All rights reserved.
//

import UIKit
import AVFoundation
import ImageIO
import CoreVideo
import CoreGraphics.CGImage
import MobileCoreServices

enum cutVideoType {
    case top
    case middle
    case bottom
    case other
}

class HRVideoUtil: NSObject {

    internal typealias convertResult = (Bool,String,String) -> Void
    
    /**
     将视频截取为正方形
     
     - parameter videoPath:  输入视频路径
     - parameter outputPath: 输出路径
     - parameter cutType:    截取类型
     - parameter result:     截取转化以后的结果回调
     */
    static func cutVideoToSquareRect(videoPath:String,outputPath:String,cutType:cutVideoType,result:convertResult){
        let asset:AVAsset? = AVAsset.init(URL: NSURL.init(fileURLWithPath: videoPath))
        if asset == nil{
            print("read video with path" + videoPath + "failed")
            result(false,"input video file is not avaliable","no file output")
            return
        }
        
        let clipVideoTrack:AVAssetTrack? = asset?.tracksWithMediaType(AVMediaTypeVideo)[0]
        
        let videoCompostion:AVMutableVideoComposition! = AVMutableVideoComposition.init()
        videoCompostion.frameDuration = CMTimeMake(1, 30)
        videoCompostion.renderSize = CGSizeMake((clipVideoTrack?.naturalSize.height)!, (clipVideoTrack?.naturalSize.height)!)
        
        let instruction:AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction.init()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))
        
        let transformer:AVMutableVideoCompositionLayerInstruction? = AVMutableVideoCompositionLayerInstruction.init(assetTrack: clipVideoTrack!)
        
        var t1:CGAffineTransform!
        switch cutType {
        case .top:
            t1 = CGAffineTransformMakeTranslation(clipVideoTrack!.naturalSize.height, 0 )
        case .middle:
            t1 = CGAffineTransformMakeTranslation(clipVideoTrack!.naturalSize.height, -(clipVideoTrack!.naturalSize.width - clipVideoTrack!.naturalSize.height)/2)
        case .bottom:
            t1 = CGAffineTransformMakeTranslation(clipVideoTrack!.naturalSize.height, (clipVideoTrack!.naturalSize.width - clipVideoTrack!.naturalSize.height)/2)
        default:
            t1 = CGAffineTransformMakeTranslation(clipVideoTrack!.naturalSize.height, -(clipVideoTrack!.naturalSize.width - clipVideoTrack!.naturalSize.height)/2)
        }
        
        let t2:CGAffineTransform = CGAffineTransformRotate(t1,CGFloat(M_PI_2))
        
        let finalTransform = t2
        transformer?.setTransform(finalTransform, atTime: kCMTimeZero)
        instruction.layerInstructions = [transformer!]
        videoCompostion.instructions = [instruction]
        
        do {
            try NSFileManager.defaultManager().removeItemAtURL(NSURL.init(fileURLWithPath: outputPath))
        } catch {
            print(error)
        }
        
        let exporter:AVAssetExportSession! = AVAssetExportSession.init(asset: asset!, presetName: AVAssetExportPresetHighestQuality)
        exporter.videoComposition = videoCompostion
        exporter.outputURL = NSURL.init(fileURLWithPath: outputPath)
        exporter.outputFileType = AVFileTypeMPEG4
        
        exporter.exportAsynchronouslyWithCompletionHandler { 
            dispatch_async(dispatch_get_main_queue()){
                print("exported success")
                result(true,"exported success",outputPath)
            }
        }
    }
    
    /**
     向视频中加入声音
     
     - parameter videoPath: 视频路径
     - parameter audioPath: 声音路径
     - parameter result:    处理结果回调
     */
    static func mixAudioToVideo(videoPath:String,audioPath:String,result:convertResult){
        let mixComposition:AVMutableComposition = AVMutableComposition.init()
        let audioInputUrl:NSURL! = NSURL.init(fileURLWithPath: audioPath)
        let videoInputUrl:NSURL! = NSURL.init(fileURLWithPath: videoPath)
        
        let docPath:String = NSHomeDirectory().stringByAppendingString("/Documents")
        let outPutFilePath:String! = docPath.stringByAppendingString("/mixed"+videoPath.componentsSeparatedByString("/").last!)
        let outPutFileUrl:NSURL = NSURL.init(fileURLWithPath: outPutFilePath)
        
        if (NSFileManager.defaultManager().fileExistsAtPath(videoPath) == false){
            result(false,"video not exist","")
            return
        }
        if (NSFileManager.defaultManager().fileExistsAtPath(audioPath) == false){
            result(false,"audio not exist","")
            return
        }
        if (NSFileManager.defaultManager().fileExistsAtPath(outPutFilePath) == true){
            do {
                try NSFileManager.defaultManager().removeItemAtPath(outPutFilePath)
            } catch {
                print(error)
            }
        }
        
        let audioAsset:AVURLAsset = AVURLAsset.init(URL: audioInputUrl)
        let audioTimeRange:CMTimeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration)
        let b_compositionAudioTrack:AVMutableCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
        do {
            try b_compositionAudioTrack.insertTimeRange(audioTimeRange, ofTrack: audioAsset.tracksWithMediaType(AVMediaTypeAudio)[0], atTime: kCMTimeZero)
        } catch {
            print(error)
        }
        
        let videoAsset:AVURLAsset = AVURLAsset.init(URL: videoInputUrl)
        let videoTimeRange:CMTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        let compositionVideoTrack:AVMutableCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        if (videoAsset.tracksWithMediaType(AVMediaTypeVideo).count != 0){
            do {
                try compositionVideoTrack.insertTimeRange(videoTimeRange, ofTrack: videoAsset.tracksWithMediaType(AVMediaTypeVideo)[0], atTime: kCMTimeZero)
            } catch {
                print(error)
            }
        }
        
        let assetExport:AVAssetExportSession = AVAssetExportSession.init(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
        assetExport.outputFileType = AVFileTypeMPEG4
        assetExport.outputURL = outPutFileUrl
        
        assetExport.exportAsynchronouslyWithCompletionHandler {
            let status = assetExport.status
            switch status{
            case AVAssetExportSessionStatus.Failed:
                result(false,"","")
            case AVAssetExportSessionStatus.Exporting:
                print("exporting...")
            case AVAssetExportSessionStatus.Completed:
                result(true,"",outPutFilePath)
            default:
                result(false,"","")
            }
        }
    }
    
    /**
     将一组图片转化为视频
     
     - parameter imagePaths: 图片路径数组
     - parameter audioPath:  声音文件路径
     - parameter result:     处理结果回调
     */
    static func saveImagesToVideo(imagePaths:Array<String>,audioPath:String,result:convertResult){
        if (imagePaths.count == 0){
            result(false,"no images input","")
            return
        }
        
        let timeString = NSDate.init().timeIntervalSince1970
        let fileName:String! = String.init(format: "video%llu.mp4", timeString)
        let docPath:String! = NSHomeDirectory().stringByAppendingString("/Documents")
        
        let firstImg:UIImage = UIImage.init(contentsOfFile: imagePaths[0])!
        let size:CGSize = firstImg.size
        
        var videoWriter:AVAssetWriter!
        do {
            try videoWriter = AVAssetWriter.init(URL: NSURL.init(fileURLWithPath: docPath.stringByAppendingString("/").stringByAppendingString(fileName)), fileType: AVFileTypeMPEG4)
        } catch {
            print(error)
        }
        
        let videoSettings:Dictionary = [AVVideoCodecKey:AVVideoCodecH264,AVVideoWidthKey:NSNumber.init(float: Float(size.width)),AVVideoHeightKey:NSNumber.init(float: Float(size.height))]
        
        let writerInput:AVAssetWriterInput = AVAssetWriterInput.init(mediaType: AVMediaTypeVideo, outputSettings: videoSettings)
        let sourcePixelBufferAttDic:Dictionary = [String(kCVPixelBufferPixelFormatTypeKey):kCVPixelFormatType_32ARGB as! AnyObject]
        
        let adaptor:AVAssetWriterInputPixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor.init(assetWriterInput: writerInput, sourcePixelBufferAttributes: sourcePixelBufferAttDic)
        if(videoWriter.canAddInput(writerInput) == true){
            videoWriter.addInput(writerInput)
        }
        
        videoWriter.startWriting()
        videoWriter.startSessionAtSourceTime(kCMTimeZero)
     
        //start combine images
        let dispathQueue = dispatch_queue_create("mediaInputQueue", nil)
        var frame:Int = 0
        
        writerInput.requestMediaDataWhenReadyOnQueue(dispathQueue) { 
            while(writerInput.readyForMoreMediaData){
                if (++frame >= imagePaths.count){
                    writerInput.markAsFinished()
                    videoWriter.finishWritingWithCompletionHandler({ 
                        result(true,"",docPath.stringByAppendingString("/").stringByAppendingString(fileName))
                    })
                }
                
                let info:UIImage = UIImage.init(contentsOfFile: imagePaths[frame])!
                let buffer:CVPixelBufferRef? = HRVideoUtil.pixelBufferFromCGImage(info.CGImage!, size: size)
                if (buffer != nil){
                    if(adaptor.appendPixelBuffer(buffer!, withPresentationTime: CMTimeMake(Int64(frame),24)) == false){
                        result(false,"","")
                    }
                }
            }
        }
    }
    
    static func pixelBufferFromCGImage(image:CGImageRef,size:CGSize) -> CVPixelBufferRef{
        let frameSize:CGSize = CGSizeMake(CGFloat(CGImageGetWidth(image)),CGFloat(CGImageGetHeight(image)))
        let options:Dictionary = [String(kCVPixelBufferCGImageCompatibilityKey):NSNumber.init(bool: true),String(kCVPixelBufferCGBitmapContextCompatibilityKey):NSNumber.init(bool: true)]
        var pxbuffer:CVPixelBufferRef?
        let status:CVReturn = CVPixelBufferCreate(kCFAllocatorDefault, Int(frameSize.width), Int(frameSize.height), kCVPixelFormatType_32ARGB, options, &pxbuffer)
        
        if (status != kCVReturnSuccess || pxbuffer == nil){
            print("error status: " + String(status))
        }
        
        CVPixelBufferLockBaseAddress(pxbuffer!, 0)
        
        let rgbColorSpace:CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.None.rawValue)
        
        let context:CGContextRef = CGBitmapContextCreate(CVPixelBufferGetBaseAddress(pxbuffer!), Int(frameSize.width), Int(frameSize.height), 8,CVPixelBufferGetBytesPerRow(pxbuffer!), rgbColorSpace, bitmapInfo.rawValue)!
        CGContextDrawImage(context, CGRectMake(0, 0, frameSize.width, frameSize.height), image)
        CVPixelBufferUnlockBaseAddress(pxbuffer!, 0)
        
        return pxbuffer!
        
    }

//    CGContextDrawImage(context, CGRectMake(0, 0, frameSize.width, frameSize.height), image);
//    CGColorSpaceRelease(rgbColorSpace);
//    CGContextRelease(context);
//    
//    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
//    
//    return pxbuffer;
}
