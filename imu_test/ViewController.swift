//
//  ViewController.swift
//  test
//
//  Created by Justin Kwok Lam CHAN on 4/4/21.
//

import Charts
import UIKit
import CoreMotion
import simd

class ViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var label: UILabel!
    
    var ts: Double = 0
    var tilt_gyro_old: Double = 0
    var tilt_gyro_x: Double = 0
    var tilt_gyro_y: Double = 0
    var tilt_acce: Double = 0
    var tilt_filter: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.lineChartView.delegate = self
        
        let set_a: LineChartDataSet = LineChartDataSet(entries: [ChartDataEntry](), label: "x")
        set_a.drawCirclesEnabled = false
        set_a.setColor(UIColor.blue)
        
        let set_b: LineChartDataSet = LineChartDataSet(entries: [ChartDataEntry](), label: "y")
        set_b.drawCirclesEnabled = false
        set_b.setColor(UIColor.red)
        
        let set_c: LineChartDataSet = LineChartDataSet(entries: [ChartDataEntry](), label: "z")
        set_c.drawCirclesEnabled = false
        set_c.setColor(UIColor.green)
        self.lineChartView.data = LineChartData(dataSets: [set_a,set_b,set_c])
    }
    
    @IBAction func startSensors(_ sender: Any) {
        ts=NSDate().timeIntervalSince1970
        label.text=String(format: "%f", ts)
        startAccelerometers()
        startGyros()
        startButton.isEnabled = false
        stopButton.isEnabled = true
    }
    
    @IBAction func stopSensors(_ sender: Any) {
        stopAccels()
        stopGyros()
        startButton.isEnabled = true
        stopButton.isEnabled = false
    }
    
    let motion = CMMotionManager()
    var counter:Double = 0
    
    var timer_accel:Timer?
    var accel_file_url:URL?
    var accel_fileHandle:FileHandle?
    
    var timer_gyro:Timer?
    var gyro_file_url:URL?
    var gyro_fileHandle:FileHandle?
    
    let xrange:Double = 500
    
    func startAccelerometers() {
       // Make sure the accelerometer hardware is available.
       if self.motion.isAccelerometerAvailable {
        // sampling rate can usually go up to at least 100 hz
        // if you set it beyond hardware capabilities, phone will use max rate
          self.motion.accelerometerUpdateInterval = 1.0 / 60.0  // 60 Hz
          self.motion.startAccelerometerUpdates()
//        if motion.isMagnetometerAvailable {
//            motion.magnetometerUpdateInterval = 1.0 / 60.0  // 60 Hz
//            motion.startMagnetometerUpdates()
        
        // create the data file we want to write to
        // initialize file with header line
        do {
            // get timestamp in epoch time
            let file = "accel_file_\(ts).txt"
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                accel_file_url = dir.appendingPathComponent(file)
            }
            
            // write first line of file
            try "ts,x,y,z\n".write(to: accel_file_url!, atomically: true, encoding: String.Encoding.utf8)

            accel_fileHandle = try FileHandle(forWritingTo: accel_file_url!)
            accel_fileHandle!.seekToEndOfFile()
        } catch {
            print("Error writing to file \(error)")
        }
        
          // Configure a timer to fetch the data.
          self.timer_accel = Timer(fire: Date(), interval: (1.0/60.0),
                                   repeats: true, block: { [self] (timer) in
             // Get the accelerometer data.
              if let data = self.motion.accelerometerData {
                 let x = data.acceleration.x
                 let y = data.acceleration.y
                 let z = data.acceleration.z
//             if let data = self.motion.magnetometerData {
//                let x = data.magneticField.x
//                let y = data.magneticField.y
//                let z = data.magneticField.z
                // pesudo codes *************************
                // cos rou = z / sqrt(x^2 + y^2 +z^2)
                let bias = [0.00472, -0.02394, 0.003249]
                let cos_tilt = (z - bias[2]) / sqrt((x-bias[0])*(x-bias[0]) + (y-bias[1])*(y-bias[1]) + (z-bias[2])*(z-bias[2]))
                let tilt = acos(cos_tilt) * 180.0 / Double.pi
                self.tilt_acce = tilt
                // pesudo codes *************************
                let timestamp = NSDate().timeIntervalSince1970
                let text = "\(timestamp), \(x), \(y), \(z)\n"
                print ("A: \(text)")
                
                self.accel_fileHandle!.write(text.data(using: .utf8)!)
                
//                self.lineChartView.data?.addEntry(ChartDataEntry(x: Double(counter), y: x), dataSetIndex: 0)
//                self.lineChartView.data?.addEntry(ChartDataEntry(x: Double(counter), y: y), dataSetIndex: 1)
//                self.lineChartView.data?.addEntry(ChartDataEntry(x: Double(counter), y: z), dataSetIndex: 2)
                
//                self.lineChartView.data?.addEntry(ChartDataEntry(x: Double(counter), y: tilt), dataSetIndex: 2)  // for visualize tilt only
//
//                // refreshes the data in the graph
//                self.lineChartView.notifyDataSetChanged()
//
//                self.counter = self.counter+1
//
//                // needs to come up after notifyDataSetChanged()
//                if counter < xrange {
//                    self.lineChartView.setVisibleXRange(minXRange: 0, maxXRange: xrange)
//                }
//                else {
//                    self.lineChartView.setVisibleXRange(minXRange: counter, maxXRange: counter+xrange)
//                }
             }
          })

          // Add the timer to the current run loop.
        RunLoop.current.add(self.timer_accel!, forMode: RunLoop.Mode.default)
       }
    }
    
    func startGyros() {
       if motion.isGyroAvailable {
          self.motion.gyroUpdateInterval = 1.0 / 60.0
          self.motion.startGyroUpdates()
        
        do {
            let file = "gyro_file_\(ts).txt"
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                gyro_file_url = dir.appendingPathComponent(file)
            }
            
            try "ts,x,y,z\n".write(to: gyro_file_url!, atomically: true, encoding: String.Encoding.utf8)

            gyro_fileHandle = try FileHandle(forWritingTo: gyro_file_url!)
            gyro_fileHandle!.seekToEndOfFile()
        } catch {
            print("Error writing to file \(error)")
        }
        
          // Configure a timer to fetch the accelerometer data.
          self.timer_gyro = Timer(fire: Date(), interval: (1.0/60.0),
                 repeats: true, block: { (timer) in
             // Get the gyro data.
             if let data = self.motion.gyroData {
                let x = data.rotationRate.x
                let y = data.rotationRate.y
                let z = data.rotationRate.z
                // tilt pesudo codes *************************
                // intergrate tilt_x = tilt_x + x * delta t
                // intergrate tilt_y = tilt_y + y * delta t
                // tilt_gyro = acos((quaternion(tilt_x) * quaternion(tilt_y)).real)
                // tilt_gyro_change = tilt_gyro - tilt_gyro_old
                // tilt_filter = 0.98 * (tilt_filter + tilt_gryo_change) + 0.02 * tilt_acce
                // tilt pesudo codes *************************
                // my implementation *************************
                let bias = [0.01412, -0.001806, -0.003625]
                self.tilt_gyro_x = self.tilt_gyro_x + (x-bias[0]) * 1.0/60.0
                self.tilt_gyro_y = self.tilt_gyro_y + (y-bias[1]) * 1.0/60.0
                let q_x = simd_quatd(ix: sin(self.tilt_gyro_x/2.0), iy: 0, iz: 0, r: cos(self.tilt_gyro_x/2.0))
                let q_y = simd_quatd(ix: 0, iy: sin(self.tilt_gyro_y/2.0), iz: 0, r: cos(self.tilt_gyro_y/2.0))
                let tilt_gyro = acos(simd_mul(q_x, q_y).real) * 180.0 / Double.pi
                let tile_change = tilt_gyro - self.tilt_gyro_old
                self.tilt_gyro_old = tilt_gyro
                self.tilt_filter = 0.98 * (self.tilt_filter + tile_change) + 0.02 * (180.0-self.tilt_acce)
                // my implementation *************************
                let timestamp = NSDate().timeIntervalSince1970
                let text = "\(timestamp), \(x), \(y), \(z)\n"
                print ("G: \(text)")
                
                self.gyro_fileHandle!.write(text.data(using: .utf8)!)
                self.lineChartView.data?.addEntry(ChartDataEntry(x: Double(self.counter), y: self.tilt_filter), dataSetIndex: 0) // for visualize tilt of complementary filter only
                self.lineChartView.data?.addEntry(ChartDataEntry(x: Double(self.counter), y: 180.0-self.tilt_acce), dataSetIndex: 1) // for visualize tilt of accelerometer only
                self.lineChartView.data?.addEntry(ChartDataEntry(x: Double(self.counter), y: tilt_gyro), dataSetIndex: 2)  // for visualize tilt of gyro only
               
                // refreshes the data in the graph
                self.lineChartView.notifyDataSetChanged()
                 
                self.counter = self.counter+1
               
                // needs to come up after notifyDataSetChanged()
                 if self.counter < self.xrange {
                     self.lineChartView.setVisibleXRange(minXRange: 0, maxXRange: self.xrange)
                 }
                 else {
                     self.lineChartView.setVisibleXRange(minXRange: self.counter, maxXRange: self.counter+self.xrange)
                 }
             }
          })

          // Add the timer to the current run loop.
          RunLoop.current.add(self.timer_gyro!, forMode: RunLoop.Mode.default)
       }
    }
    
    func stopAccels() {
       if self.timer_accel != nil {
          self.timer_accel?.invalidate()
          self.timer_accel = nil

          self.motion.stopAccelerometerUpdates()
        
           accel_fileHandle!.closeFile()
       }
    }
    
    func stopGyros() {
       if self.timer_gyro != nil {
          self.timer_gyro?.invalidate()
          self.timer_gyro = nil

          self.motion.stopGyroUpdates()
          
           gyro_fileHandle!.closeFile()
       }
    }
}

