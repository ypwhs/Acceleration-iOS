//
//  ViewController.swift
//  Acceleration
//
//  Created by 杨培文 on 14/12/1.
//  Copyright (c) 2014年 杨培文. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion
import MapKit

class ViewController: UIViewController,CLLocationManagerDelegate{
    let locationManager = CLLocationManager()
    let motionManager = CMMotionManager()
    var timer:NSTimer?
    var speed = 0.01
    var dir = NSHomeDirectory()+"/Documents/out.txt"
    var file=NSFileHandle()
    var filemanager=NSFileManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate=self
        locationManager.requestAlwaysAuthorization()
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = true
        } else {
            // Fallback on earlier versions
        }

        if motionManager.accelerometerAvailable {
            motionManager.accelerometerUpdateInterval = speed
            motionManager.startAccelerometerUpdates()
            print("开始加速度检测")
        }else {
            UIAlertView(title: "提示", message: "不支持加速度的设备", delegate: nil, cancelButtonTitle: "确定").show()
            print("不支持加速度的设备")
        }
        
        if motionManager.gyroAvailable {
            motionManager.gyroUpdateInterval = speed
            motionManager.startGyroUpdates()
            print("开始角速度检测")
        }else {
            UIAlertView(title: "提示", message: "不支持陀螺仪的设备", delegate: nil, cancelButtonTitle: "确定").show()
            print("不支持陀螺仪的设备")
        }
        
        if motionManager.magnetometerAvailable {
            motionManager.magnetometerUpdateInterval = speed
            motionManager.startMagnetometerUpdates()
            print("开始磁场检测")
        }else {
            UIAlertView(title: "提示", message: "不支持磁场的设备", delegate: nil, cancelButtonTitle: "确定").show()
            print("不支持磁场的设备")
        }
        
        if motionManager.deviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = speed
            motionManager.startDeviceMotionUpdates()
            print("开始方向检测")
        }else {
            UIAlertView(title: "提示", message: "不支持方向的设备", delegate: nil, cancelButtonTitle: "确定").show()
            print("不支持方向的设备")
        }
        
        if self.view.bounds.size.width != 768 {
            print("iphone")
            scroll.contentSize=CGSize(width: 320, height: 1300)
        }
        
        
        getsize()
        file = NSFileHandle(forUpdatingAtPath: dir)!
        let de = NSUserDefaults(suiteName: "speed")
        let spd = de!.floatForKey("speed")
        if spd != 0 {
            speedslider.value = spd
        }else {
            speedslider.value=0
        }
        sliderchange(0)
    }
    
    @IBOutlet var scroll: UIScrollView!
    @IBOutlet weak var accx: UISlider!
    @IBOutlet weak var accy: UISlider!
    @IBOutlet weak var accz: UISlider!
    @IBOutlet weak var gyrox: UISlider!
    @IBOutlet weak var gyroy: UISlider!
    @IBOutlet weak var gyroz: UISlider!
    @IBOutlet weak var magx: UISlider!
    @IBOutlet weak var magy: UISlider!
    @IBOutlet weak var magz: UISlider!
    @IBOutlet weak var gpstext: UITextView!
    
    @IBOutlet weak var orix: UISlider!
    @IBOutlet weak var oriy: UISlider!
    @IBOutlet weak var oriz: UISlider!
    
    
    func setspeed(){
        motionManager.accelerometerUpdateInterval = speed
        motionManager.gyroUpdateInterval = speed
        motionManager.magnetometerUpdateInterval = speed
        motionManager.deviceMotionUpdateInterval = speed
        if timer != nil {
            timer?.invalidate()
        }
        timer=NSTimer.scheduledTimerWithTimeInterval(speed, target: self, selector: "refresh", userInfo: nil, repeats: true)
        speedlabel.text="数据采集间隔:\(Int(speed*1000))毫秒,记录速度:\(Int(4.7/speed))KB/min"
    }
    
    @IBAction func logswitch(sender: AnyObject) {
        if wirteswitch.on {
            locationManager.startUpdatingLocation()
        }else {
            locationManager.stopUpdatingLocation()
        }
    }
    
    var x:Float = 0.0,y:Float = 0.0,z:Float = 0.0,max:Float = 0.0,cos:Float = 0.0,theta:Float = 0.0
    func refresh(){
        var show=""
        if let a = motionManager.accelerometerData
        {
            x=Float(a.acceleration.x)
            y=Float(a.acceleration.y)
            z=Float(a.acceleration.z)
            accx.value=Float(a.acceleration.x)
            accy.value=Float(a.acceleration.y)
            accz.value=Float(a.acceleration.z)
            cos=sqrt((x*x+z*z)/(x*x+y*y+z*z))
            theta=acos(cos)/3.1415926*180
            write("acc,\(x),\(y),\(z)")
            show+=NSString(format: "加速度\nx=%.2f\ny=%.2f\nz=%.2f\nθ=%.2f", x,y,z,theta) as String
            if theta<1 {
                show+="\t\t水平放置"
            }else if theta>85 {
                show+="\t\t垂直放置"
            }
        }
        if let g = motionManager.gyroData{
            x = Float(g.rotationRate.x)
            y = Float(g.rotationRate.y)
            z = Float(g.rotationRate.z)
            max=Float.abs(x)
            if Float.abs(y)>max {max=Float.abs(y)}
            if Float.abs(z)>max {max=Float.abs(z)}
            
            show+=NSString(format: "\n\n陀螺仪\nx=%.2f\ny=%.2f\nz=%.2f", x,y,z) as String
            if max>0.5 {
                show+="\t\t正在转动"
            }
            write("gyro,\(x),\(y),\(z)")
            if max<5 {max=5}
            gyrox.maximumValue=max
            gyroy.maximumValue=max
            gyroz.maximumValue=max
            gyrox.minimumValue=0-max
            gyroy.minimumValue=0-max
            gyroz.minimumValue=0-max
            gyrox.value=x
            gyroy.value=y
            gyroz.value=z

        }
        if let m = motionManager.magnetometerData{
            x = Float(m.magneticField.x)
            y = Float(m.magneticField.y)
            z = Float(m.magneticField.z)

            max=Float.abs(x)
            if Float.abs(y)>max {max=Float.abs(y)}
            if Float.abs(z)>max {max=Float.abs(z)}
            if max<300 {max=300}
            magx.maximumValue=max
            magy.maximumValue=max
            magz.maximumValue=max
            magx.minimumValue=0-max
            magy.minimumValue=0-max
            magz.minimumValue=0-max
            magx.value=Float(x)
            magy.value=Float(y)
            magz.value=Float(z)
            show+=NSString(format: "\n\n磁场\nx=%.2f\ny=%.2f\nz=%.2f\n", x,y,z) as String
            write("mag,\(x),\(y),\(z)")
            if max>1000 {
                show+="检测到磁铁或磁贴"
            }
        }
        if let d = motionManager.deviceMotion?.attitude{
            x = Float(d.roll)
            y = Float(d.pitch)
            z = Float(d.yaw)
            
            x=x/3.1415926*180
            y=y/3.1415926*180
            z=z/3.1415926*180
            
            max=Float.abs(x)
            if Float.abs(y)>max {max=Float.abs(y)}
            if Float.abs(z)>max {max=Float.abs(z)}
            if max<90 {max=90}
            orix.maximumValue=max
            oriy.maximumValue=max
            oriz.maximumValue=max
            orix.minimumValue=0-max
            oriy.minimumValue=0-max
            oriz.minimumValue=0-max
            
            orix.value = Float(x)
            oriy.value = Float(y)
            oriz.value = Float(z)
            
            show+=NSString(format: "\n\n欧拉角\nrow=%.2f\npitch=%.2f\nyaw=%.2f", x,y,z) as String

            write("ori,\(x),\(y),\(z)")
        }

        showtext.text=show
    }
    
    @IBOutlet weak var showtext: UITextView!

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocation = locations[locations.count-1] 
        if(location.horizontalAccuracy>0){
            let gps="GPS信息:\n经度:\(location.coordinate.latitude)\n纬度:\(location.coordinate.longitude)"
            gpstext.text=gps
            write("gps,\(location.coordinate.latitude),\(location.coordinate.longitude)")
            print(gps)
        }
    }

    @IBAction func share(sender: AnyObject) {
        let url = NSURL(string: "file://"+dir)
        print(url)
        let controler = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
        presentViewController(controler, animated: true, completion: nil)
        if controler.respondsToSelector("popoverPresentationController") {
            let presentationController = controler.popoverPresentationController
            presentationController?.sourceView = sharebutton
        }
    }
    
    
    @IBOutlet var filesize: UILabel!
    @IBOutlet var wirteswitch: UISwitch!
    @IBOutlet var speedlabel: UILabel!
    @IBOutlet var speedslider: UISlider!
    @IBOutlet var sharebutton: UIButton!
    
    
    @IBAction func clear(sender: AnyObject) {
        file.truncateFileAtOffset(0)
        getsize()
    }
    
    @IBAction func sliderchange(sender: AnyObject) {
        let de = NSUserDefaults(suiteName: "speed")
        speed=(5+exp(Double(speedslider.value)))/1000.0
        de!.setFloat(speedslider.value, forKey: "speed")
        setspeed()
    }
    
    func write(s:String){
        if wirteswitch.on {
            let s2="\(getTime()),\(s)\n"
            file.seekToEndOfFile()
            file.writeData(s2.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
            getsize()
            print(s2)
        }
    }
    
    
    func getsize(){
        if filemanager.fileExistsAtPath(dir){
            do{
                var s = try filemanager.attributesOfItemAtPath(dir)
                let sz = Int(s["NSFileSize"] as! Int)
                if sz<1048576{
                    filesize.text=NSString(format: "%.3fKB", Double(sz)/1024.0) as String
                }else {
                    filesize.text=NSString(format: "%.3fMB", Double(sz)/1048576.0) as String
                }
            }catch{
                print("创建文件失败")
            }
        }else {
            do{
                try "".writeToFile(dir, atomically: true, encoding: NSUTF8StringEncoding)
            }catch{
                
            }
        }
    }
    
    @IBAction func map(sender: AnyObject) {
        locationManager.stopUpdatingLocation()
    }
    
    func getTime() -> String{
        let timespan = NSDate().timeIntervalSince1970*1000
        return "\(Int64(timespan))"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

