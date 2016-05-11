//
//  ViewController.swift
//  HRSwiftUtil
//
//  Created by ZhangHeng on 16/4/25.
//  Copyright © 2016年 ZhangHeng. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let mySwitch:HRCustomSwitch = HRCustomSwitch.init(frame: CGRectMake(10, 30, 60, 25))
        self.view.addSubview(mySwitch)
        
        let roundView:HRRoundView = HRRoundView.init(frame: CGRectMake(20, 90, 100, 100))
        roundView.roundType = HRRoundType.left
        roundView.backgroundColor = UIColor.yellowColor()
        self.view.addSubview(roundView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

