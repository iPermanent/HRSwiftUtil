//
//  HMCustomSwitch.swift
//  iHiho
//
//  Created by ZhangHeng on 16/4/23.
//  Copyright © 2016年 ZhangHeng. All rights reserved.
//

import UIKit

@objc
protocol HRCustomSwitchDelegate {
    optional func switchValueChanged(isOpen: Bool);
}

class HRCustomSwitch: UIView {
    var isOn:Bool!{
        didSet(newValue){
            if isOn == false{
                self.maskSwitch.frame = CGRectMake(1, 1, self.frame.size.height - 2, self.frame.size.height - 2)
                self.backgroundColor = UIColor.grayColor()
            }else{
                self.maskSwitch.frame = CGRectMake(self.frame.size.width-self.frame.size.height+1, 1, self.frame.size.height - 2, self.frame.size.height - 2)
                self.backgroundColor = UIColor.init(red: 185/255.0, green: 233/255.0, blue: 134/255.0, alpha: 1)
            }
        }
    }
    var delegate:HRCustomSwitchDelegate?
    
    
    private var onLabel:UILabel!
    private var offLabel:UILabel!
    private var maskSwitch:UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isOn = true
        self.backgroundColor = UIColor.init(red: 155/255.0, green: 233/255.0, blue: 114/255.0, alpha: 1)
        self.layer.cornerRadius = frame.size.height/2
        self.clipsToBounds = true
        
        onLabel = UILabel.init(frame: CGRectMake(5, 0, frame.size.width/3, frame.size.height))
        onLabel.textColor = UIColor.whiteColor()
        onLabel.text = "ON"
        onLabel.font = UIFont.systemFontOfSize(10)
        self.addSubview(onLabel)
        
        offLabel = UILabel.init(frame: CGRectMake(frame.size.width/3*2 - 10,0, frame.size.height, frame.size.height))
        offLabel.textColor = UIColor.whiteColor()
        offLabel.textAlignment = NSTextAlignment.Right
        offLabel.font = onLabel.font
        offLabel.text = "OFF "
        self.addSubview(offLabel)
        
        maskSwitch = UIView.init(frame: CGRectMake(frame.size.width-frame.size.height+1, 1, frame.size.height - 2, frame.size.height - 2))
        maskSwitch.backgroundColor = UIColor.whiteColor()
        maskSwitch.layer.cornerRadius = frame.size.height/2 - 1;
        maskSwitch.clipsToBounds = true
        self.addSubview(maskSwitch)
        self.userInteractionEnabled = true
        let tap:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(HRCustomSwitch.changeSwitch))
        self.addGestureRecognizer(tap)
    }
    
    func changeSwitch(){
        UIView.animateWithDuration(0.2) {
            if (self.isOn == true){
                self.maskSwitch.frame = CGRectMake(1, 1, self.frame.size.height - 2, self.frame.size.height - 2)
                self.backgroundColor = UIColor.grayColor()
            }else{
                self.maskSwitch.frame = CGRectMake(self.frame.size.width-self.frame.size.height+1, 1, self.frame.size.height - 2, self.frame.size.height - 2)
                self.backgroundColor = UIColor.init(red: 155/255.0, green: 233/255.0, blue: 114/255.0, alpha: 1)
            }
        }
        
        self.isOn = !self.isOn
        if self.delegate != nil{
            self.delegate?.switchValueChanged!(self.isOn)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
