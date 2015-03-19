//
//  UIViewController.swift
//  Acceleration
//
//  Created by 杨培文 on 14/12/1.
//  Copyright (c) 2014年 杨培文. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion

class Coltroler2: UIViewController{
    var timer:NSTimer?
    let motionManager = CMMotionManager()
    var speed = 0.01
    var text=[UILabel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if motionManager.accelerometerAvailable {
            motionManager.accelerometerUpdateInterval = speed
            motionManager.startAccelerometerUpdates()
            println("开始加速度检测")
        }else {
            var alert = UIAlertView(title: "提示", message: "不支持加速度的设备", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
            println("不支持加速度的设备")
        }
        
        if motionManager.gyroAvailable {
            motionManager.gyroUpdateInterval = speed
            motionManager.startGyroUpdates()
            println("开始角速度检测")
        }else {
            var alert = UIAlertView(title: "提示", message: "不支持陀螺仪的设备", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
            println("不支持陀螺仪的设备")
        }
        
        if motionManager.magnetometerAvailable {
            motionManager.magnetometerUpdateInterval = speed
            motionManager.startMagnetometerUpdates()
            println("开始磁场检测")
        }else {
            println("不支持磁场传感器的设备")
        }

        for i in 1...16{
            var t = UILabel(frame: CGRect(x: 14, y: 48+i*32, width: 400, height: 32))
            t.font=UIFont(name: "Helvetica", size: 32)
            t.text = "\(i)"
            view.addSubview(t)
            text.append(t)
        }
        
        timer=NSTimer.scheduledTimerWithTimeInterval(speed, target: self, selector: "refresh", userInfo: nil, repeats: true)
    }
    var x:Float = 0.0,y:Float = 0.0,z:Float = 0.0,max:Float = 0.0,cos:Float = 0.0,theta:Float = 0.0
    var show=""

    func refresh(){
        if let a = motionManager.accelerometerData
        {
            x=Float(a.acceleration.x)
            y=Float(a.acceleration.y)
            z=Float(a.acceleration.z)
            cos = sqrt((x*x+z*z)/(x*x+y*y+z*z))
            theta = acos(cos)/3.1415926*180
            show=NSString(format: "加速度信息:\nx=%.2f\ny=%.2f\nz=%.2f\nθ=%.1f\n\n", x,y,z,theta)
        }
        if let g = motionManager.gyroData{
            x = Float(g.rotationRate.x)
            y = Float(g.rotationRate.y)
            z = Float(g.rotationRate.z)
            max=Float.abs(x)
            if Float.abs(y)>max {max=Float.abs(y)}
            if Float.abs(z)>max {max=Float.abs(z)}
            if max<3 {max=3}
            show+=NSString(format: "陀螺仪信息:\nx=%.2f\ny=%.2f\nz=%.2f\n\n", x,y,z)
        }
        if let m = motionManager.magnetometerData{
            x = Float(m.magneticField.x)
            y = Float(m.magneticField.y)
            z = Float(m.magneticField.z)
            
            max=Float.abs(x)
            if Float.abs(y)>max {max=Float.abs(y)}
            if Float.abs(z)>max {max=Float.abs(z)}
            if max<300 {max=300}
            show+=NSString(format: "磁场信息:\nx=%.0f\ny=%.0f\nz=%.0f\n", x,y,z)
            if max>1000 {
                show+="检测到磁铁或磁贴"
            }
        }
        //show
        var sz = show.componentsSeparatedByString("\n")
        for i in 0...15{
            if i<sz.count{
                text[i].text=sz[i]
            }else {
                text[i].text=""
            }
        }
        
    }

    @IBAction func back(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: { () -> Void in})
    }
}