# Estimate Tilt Angle of Phone using Gyroscope and Accelerometer

This is an implementation of estimating and trackiing the tilt angle of a moving or static IOS phone with the data from gyroscope and accelerometer (IMU on phone). The code is adapted from github repository from [Justin Chan](https://github.com/justinklchan/imu_iphone)

## What is it
This project leverages the gyroscope and accelerometer already embedded in most commodity phone devices to estimate the tilt angle of phone when it is moving. The tilt angle is defined as the angle ρ between the gravitational vector measured by the accelerometer and the initial orientation with the gravitational field pointing downwards along the $z$-axis. 

<img width="497" alt="Screen Shot 2022-06-01 at 1 59 57 PM" src="https://user-images.githubusercontent.com/46943965/171500709-5eb50fd9-6cc2-4431-891c-5483a58a3ff5.png">

To do this, three ways of usiing differeng sensors were implemented here.

### 1) Accelerometer-based tilt estimation:

If the accelerometer reading is $G_p$, then in the absence of linear acceleration, then the tilt angle ρ is calculated based on below [formula](https://www.nxp.com/files-static/sensors/doc/app_note/AN3461.pdf):

<img width="461" alt="Screen Shot 2022-04-27 at 4 30 14 PM" src="https://user-images.githubusercontent.com/46943965/171502893-0bfb2a96-433c-45eb-80fb-85fa50cf7488.png">

### 2) Gyroscope-based tilt estimation:

First calculate the accumulated rotation angle on $x$ and $y$ axes, and then calculate the [quaternion multiplication](http://msl.cs.illinois.edu/~lavalle/papers/LavYerKatAnt14.pdf) of $x$, $y$ rotations angles, finally get the real part of quaternion multiplication resulst and convert it to the tilt.

### 3) Combination of accelerometer and gyroscope by applying complementary filter
angle $= 0.98 * ($ angle $+$ change of gyroscope_tilt $) + 0.02 * ($ accelerometer_tilt $)$
## How to use

To test this program, use Xcode, connect your phone to laptop -> choose your phone as device at the top -> select your project in the left 'buildtime' window -> select project in 'target' -> 'singning and capabilities', sign in your account and change the bundle identifier (add one number at the end is fine) -> build and run the project.

Note that all the code changes are in the file './imu_test/ViewController.swift'

## Result
We test put phone on table and make it static. The tilt estimation results for a long time are shown in below figure, where the red color represents the estimation results for accelerometer, the blue color represents the results for gyroscope, and the blue color represents the results for complementary filter with parameter 0.98, 0.02

<img width="657" alt="Screen Shot 2022-06-01 at 2 57 08 PM" src="https://user-images.githubusercontent.com/46943965/171508722-5dee7e61-0fc9-4182-a3e7-cfa05efd44e2.png">

## Demo
Demo of running code on iphone in real time:

https://user-images.githubusercontent.com/46943965/170893234-9c12533f-29b1-4c13-a56b-96caf32e4c79.mp4

