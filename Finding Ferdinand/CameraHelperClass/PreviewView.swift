//
//  PreviewView.swift
//  VisionDetection
//
//  Created by Wei Chieh Tseng on 09/06/2017.
//  Copyright © 2017 Willjay. All rights reserved.
//

import UIKit
import Vision
import AVFoundation


public enum SessionSetupResult {
    case success
    case notAuthorized
    case configurationFailed
}

class PreviewView: UIView {
    
    var lipColor:UIColor!
    private var maskLayer = [CAShapeLayer]()
    private var currentCameraDevice:AVCaptureDevice?
    
    // MARK: AV capture properties
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    // Create a new layer drawing the bounding box
    private func createLayer(in rect: CGRect) -> CAShapeLayer{
        
        let mask = CAShapeLayer()
        mask.frame = rect
        mask.cornerRadius = 10
        mask.opacity = 0.75
        mask.borderColor = UIColor.clear.cgColor
        mask.borderWidth = 2.0
        
        maskLayer.append(mask)
        layer.insertSublayer(mask, at: 1)
        
        return mask
    }
    
    func drawFaceboundingBox(face : VNFaceObservation) {
        
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -frame.height)
        
        let translate = CGAffineTransform.identity.scaledBy(x: frame.width, y: frame.height)
        
        // The coordinates are normalized to the dimensions of the processed image, with the origin at the image's lower-left corner.
        let facebounds = face.boundingBox.applying(translate).applying(transform)
        
        _ = createLayer(in: facebounds)        
    }
    
    func drawFaceWithLandmarks(face: VNFaceObservation) {
        
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -frame.height)
        
        let translate = CGAffineTransform.identity.scaledBy(x: frame.width, y: frame.height)
        
        // The coordinates are normalized to the dimensions of the processed image, with the origin at the image's lower-left corner.
        let facebounds = face.boundingBox.applying(translate).applying(transform)
        
        let frameCenter = CGPoint(x: frame.width / 2, y: frame.height / 2)
        let radio = CGFloat(1280.0 / 960.0)
        let newFaceBounds = CGRect(x: facebounds.origin.x,
                             y: frameCenter.y + (facebounds.origin.y - frameCenter.y) * radio,
                             width: facebounds.size.width,
                             height: facebounds.size.height * radio)
        
        // Draw the bounding rect
        let faceLayer = createLayer(in: newFaceBounds)
        
        // Draw the landmarks
        drawLandmarks(on: faceLayer, faceOuterLandmarkRegion: (face.landmarks?.outerLips)!, faceInnerLandmarkRegion: (face.landmarks?.innerLips)!, fillColor: lipColor != nil ? lipColor:UIColor.yellow)
    }
    
    func drawLandmarks(on targetLayer: CALayer, faceOuterLandmarkRegion: VNFaceLandmarkRegion2D, faceInnerLandmarkRegion: VNFaceLandmarkRegion2D, fillColor: UIColor, isClosed: Bool = true) {
        let rect: CGRect = targetLayer.frame
        
        var outerPoints: [CGPoint] = []
        for i in 0..<faceOuterLandmarkRegion.pointCount {
            let point = faceOuterLandmarkRegion.normalizedPoints[i]
            outerPoints.append(point)
        }
        
        var innerPoints: [CGPoint] = []
        for i in 0..<faceInnerLandmarkRegion.pointCount {
            let point = faceInnerLandmarkRegion.normalizedPoints[i]
            innerPoints.append(point)
        }
        
        let landmarkLayer = drawPointsOnLayer(rect: rect, landmarkOuterPoints: outerPoints, landmarkInnerPoints: innerPoints, fillColor: fillColor, isClosed: isClosed)
        
        // Change scale, coordinate systems, and mirroring
        landmarkLayer.transform = CATransform3DMakeAffineTransform(
            CGAffineTransform.identity
                .scaledBy(x: rect.width, y: -rect.height)
                .translatedBy(x: 0, y: -1)
        )

        targetLayer.insertSublayer(landmarkLayer, at: 1)
    }
    
    func drawPointsOnLayer(rect:CGRect, landmarkOuterPoints: [CGPoint], landmarkInnerPoints: [CGPoint], fillColor: UIColor, isClosed: Bool = true) -> CALayer {
        let outerLinePath = UIBezierPath()
        outerLinePath.move(to: landmarkOuterPoints.first!)
        for point in landmarkOuterPoints.dropFirst() {
            outerLinePath.addLine(to: point)
        }
        if isClosed {
            outerLinePath.addLine(to: landmarkOuterPoints.first!)
        }
        
        let innerLinePath = UIBezierPath()
        innerLinePath.move(to: landmarkInnerPoints.first!)
        for point in landmarkInnerPoints.dropFirst() {
            innerLinePath.addLine(to: point)
        }
        if isClosed {
            innerLinePath.addLine(to: landmarkInnerPoints.first!)
        }
        
        outerLinePath.append(innerLinePath)
        outerLinePath.usesEvenOddFillRule = true
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = outerLinePath.cgPath
        lineLayer.fillRule = kCAFillRuleEvenOdd
        lineLayer.fillColor = fillColor.cgColor
        lineLayer.opacity = 0.5
        lineLayer.lineWidth = 0.005
        
        return lineLayer
    }
    
    func removeMask() {
        for mask in maskLayer {
            mask.removeFromSuperlayer()
        }
        maskLayer.removeAll()
    }
    
    
    
    public var delegate: AVCaptureVideoDataOutputSampleBufferDelegate!
    
    private var devicePosition: AVCaptureDevice.Position = .back
    
    public let avCaptureSession = AVCaptureSession()
    
    private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], target: nil) // Communicate with the session and other session objects on this queue.
    
    private var setupResult: SessionSetupResult = .success
    var photoOutput:AVCapturePhotoOutput?
    
    private var videoDeviceInput:   AVCaptureDeviceInput!
    
    private var videoDataOutput:    AVCaptureVideoDataOutput!
    private var videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
    
    func initSetupResult() {
        /*
         Check video authorization status. Video access is required and audio
         access is optional. If audio access is denied, audio is not recorded
         during movie recording.
         */
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video){
        case .authorized:
            // The user has previously granted access to the camera.
            break
            
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. We suspend the session queue to delay session
             setup until the access request has completed.
             */
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [unowned self] granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
        default:
            // The user has previously denied access.
            setupResult = .notAuthorized
        }        
    }
    
    func startSessionQueue() {
        /*
         Setup the capture session.
         In general it is not safe to mutate an AVCaptureSession or any of its
         inputs, outputs, or connections from multiple threads at the same time.
         
         Why not do all of this on the main queue?
         Because AVCaptureSession.startRunning() is a blocking call which can
         take a long time. We dispatch session setup to the sessionQueue so
         that the main queue isn't blocked, which keeps the UI responsive.
         */
        
        sessionQueue.async { [unowned self] in
            if self.videoDataOutput == nil {
                self.session = self.avCaptureSession
                self.configureSession()
            }
            
            self.setCameraSession()
        }
    }
    
    func stopSessionQueue() {
        sessionQueue.async { [unowned self] in
            if self.setupResult == .success {
                self.avCaptureSession.stopRunning()
                self.removeObservers()
            }
        }
    }
    
    func capturePhotoWithLevelsOfExposure(_ photoExposureLevels:NSArray) {
        let videoPreviewLayerVideoOrientation: AVCaptureVideoOrientation? = self.videoPreviewLayer.connection?.videoOrientation
        sessionQueue.async(execute: {() -> Void in
            // Update the photo output's connection to match the video orientation of the video preview layer.
            let photoOutputConnection: AVCaptureConnection? = self.photoOutput?.connection(with: .video)
            photoOutputConnection?.videoOrientation = videoPreviewLayerVideoOrientation!
            let rawFormat = (self.photoOutput?.availableRawPhotoPixelFormatTypes.last ?? 0) as? OSType
            
            // Resizung photo quality
            let codecSettings = [
                AVVideoQualityKey : 1.0
            ]
            let photoBracketSettings = AVCapturePhotoBracketSettings(rawPixelFormatType: rawFormat!, processedFormat: [
                AVVideoCodecKey : AVVideoCodecType.jpeg,
                AVVideoCompressionPropertiesKey : codecSettings
                ], bracketedSettings: photoExposureLevels as! [AVCaptureBracketedStillImageSettings])
            photoBracketSettings.isLensStabilizationEnabled = (self.photoOutput?.isLensStabilizationDuringBracketedCaptureSupported)!
            photoBracketSettings.isHighResolutionPhotoEnabled = true
//            self.photoOutput?.capturePhoto(with: photoBracketSettings, delegate: self)    KKK
        })
    }    
    
    func setCameraSession() {
        sessionQueue.async { [unowned self] in
            switch self.setupResult {
            case .success:
                // Only setup observers and start the session running if setup succeeded.
                self.addObservers()
                self.avCaptureSession.startRunning()
                
            case .notAuthorized:
                print("AVCamBarcode doesn't have permission to use the camera, please change privacy settings")
//                DispatchQueue.main.async { [unowned self] in
//                    let message = NSLocalizedString("AVCamBarcode doesn't have permission to use the camera, please change privacy settings", comment: "Alert message when the user has denied access to the camera")
//                    let    alertController = UIAlertController(title: "AppleFaceDetection", message: message, preferredStyle: .alert)
//                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
//                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .`default`, handler: { action in
//                        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
//                    }))
//
////                    self.present(alertController, animated: true, completion: nil)
//                }
                
            case .configurationFailed:
                print("Alert message when something goes wrong during capture session configuration")
//                DispatchQueue.main.async { [unowned self] in
//                    let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
//                    let alertController = UIAlertController(title: "AppleFaceDetection", message: message, preferredStyle: .alert)
//                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
//
////                    self.present(alertController, animated: true, completion: nil)
//                }
            }
        }
    }
    
    func exifOrientationFromDeviceOrientation() -> UInt32 {
        enum DeviceOrientation: UInt32 {
            case top0ColLeft = 1
            case top0ColRight = 2
            case bottom0ColRight = 3
            case bottom0ColLeft = 4
            case left0ColTop = 5
            case right0ColTop = 6
            case right0ColBottom = 7
            case left0ColBottom = 8
        }
        var exifOrientation: DeviceOrientation
        
        switch UIDevice.current.orientation {
        case .portraitUpsideDown:
            exifOrientation = .left0ColBottom
        case .landscapeLeft:
            exifOrientation = devicePosition == .front ? .bottom0ColLeft : .top0ColRight
        case .landscapeRight:
            exifOrientation = devicePosition == .front ? .top0ColRight : .bottom0ColLeft
        default:
            exifOrientation = .left0ColTop
        }
        
        return exifOrientation.rawValue
    }
    
    private func availableSessionPresets() -> [String] {
        let allSessionPresets = [AVCaptureSession.Preset.photo,
                                 AVCaptureSession.Preset.low,
                                 AVCaptureSession.Preset.medium,
                                 AVCaptureSession.Preset.high,
                                 AVCaptureSession.Preset.cif352x288,
                                 AVCaptureSession.Preset.vga640x480,
                                 AVCaptureSession.Preset.hd1280x720,
                                 AVCaptureSession.Preset.iFrame960x540,
                                 AVCaptureSession.Preset.iFrame1280x720,
                                 AVCaptureSession.Preset.hd1920x1080,
                                 AVCaptureSession.Preset.hd4K3840x2160]
        
        var availableSessionPresets = [String]()
        for sessionPreset in allSessionPresets {
            if avCaptureSession.canSetSessionPreset(sessionPreset) {
                availableSessionPresets.append(sessionPreset.rawValue)
            }
        }
        
        return availableSessionPresets
    }
    
    func setupCorrectFramerate(currentCamera: AVCaptureDevice) {
        for vFormat in currentCamera.formats {
            //see available types
            //print("\(vFormat) \n")
            
            var ranges = vFormat.videoSupportedFrameRateRanges as [AVFrameRateRange]
            let frameRates = ranges[0]
            
            do {
                //set to 240fps - available types are: 30, 60, 120 and 240 and custom
                // lower framerates cause major stuttering
                if frameRates.maxFrameRate == 240 {
                    try currentCamera.lockForConfiguration()
                    currentCamera.activeFormat = vFormat as AVCaptureDevice.Format
                    //for custom framerate set min max activeVideoFrameDuration to whatever you like, e.g. 1 and 180
                    currentCamera.activeVideoMinFrameDuration = frameRates.minFrameDuration
                    currentCamera.activeVideoMaxFrameDuration = frameRates.maxFrameDuration
                }
            } catch {
                print("Could not set active format")
                print(error)
            }
        }
    }
    
    func configureSession() {
        if self.setupResult != .success {
            return
        }
        
        avCaptureSession.beginConfiguration()
        avCaptureSession.sessionPreset = .inputPriority
        
        // Add video input.
        do {
            var defaultVideoDevice: AVCaptureDevice?
            
            /*
             // Choose the back dual camera if available, otherwise default to a wide angle camera.
             if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: AVMediaType.video, position: .front) {
             defaultVideoDevice = dualCameraDevice
             } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) {
             defaultVideoDevice = backCameraDevice
             } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) {
             defaultVideoDevice = frontCameraDevice
             }
             */
            
            defaultVideoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
            self.currentCameraDevice = defaultVideoDevice
            
            enableContinuousAutoExposure()
//            if ([defaultVideoDevice lockForConfiguration:&error]) {
//                [defaultVideoDevice setExposureModeCustomWithDuration:exposureDuration ISO:AVCaptureISOCurrent completionHandler:nil];
//                [defaultVideoDevice unlockForConfiguration];
//            }
            
            
//            do {
//                try defaultVideoDevice?.lockForConfiguration()
//                let isExposure = defaultVideoDevice?.isExposureModeSupported(.continuousAutoExposure)
//                defaultVideoDevice?.exposureMode = .continuousAutoExposure
//                defaultVideoDevice?.setExposureModeCustom(duration: AVCaptureDevice.currentExposureDuration, iso: 0, completionHandler: nil)
//                defaultVideoDevice?.unlockForConfiguration()
//            } catch let error {
//                print("Exception error: \(error)")
//            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice!)
            
            if avCaptureSession.canAddInput(videoDeviceInput) {
                avCaptureSession.addInput(videoDeviceInput)
                
                var maxFps: Double = 0
                var finalFormat:AVCaptureDevice.Format?
                
                for vFormat in defaultVideoDevice!.formats {
                    var ranges = vFormat.videoSupportedFrameRateRanges as [AVFrameRateRange]
                    let frameRates = ranges[0]
                    
                    if frameRates.maxFrameRate >= maxFps && frameRates.maxFrameRate <= 240 {
                        maxFps = frameRates.maxFrameRate
                        finalFormat = vFormat // as! AVCaptureDevice.Format
                    }
                }
                
                if maxFps != 0 {
                    let timeValue = Int64(1200.0 / maxFps)
                    let timeScale: Int64 = 1200
                    do {
                        try defaultVideoDevice?.lockForConfiguration()
                        defaultVideoDevice?.activeFormat = finalFormat!
                        defaultVideoDevice?.activeVideoMinFrameDuration = CMTimeMake(timeValue, Int32(timeScale))
                        defaultVideoDevice?.activeVideoMaxFrameDuration = CMTimeMake(timeValue, Int32(timeScale))
                        defaultVideoDevice?.unlockForConfiguration()
                    } catch let error {
                        print("Exception error: \(error)")
                    }
                }
                
                self.videoDeviceInput = videoDeviceInput
                DispatchQueue.main.async {
                    let statusBarOrientation = UIApplication.shared.statusBarOrientation
                    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                    if statusBarOrientation != .unknown {
                        if let videoOrientation = statusBarOrientation.videoOrientation {
                            initialVideoOrientation = videoOrientation
                        }
                    }
                    
                    self.videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    self.videoPreviewLayer.connection!.videoOrientation = initialVideoOrientation
                }
            } else {
                print("Could not add video device input to the session")
                setupResult = .configurationFailed
                avCaptureSession.commitConfiguration()
                return
            }
        } catch {
            print("Could not create video device input: \(error)")
            setupResult = .configurationFailed
            avCaptureSession.commitConfiguration()
            return
        }
        
        // add output
        let photoOutput:AVCapturePhotoOutput = AVCapturePhotoOutput()
        if self.avCaptureSession.canAddOutput(photoOutput) == true {
            self.avCaptureSession.addOutput(photoOutput)
            self.photoOutput = photoOutput
            self.photoOutput?.isHighResolutionCaptureEnabled = true;
            self.photoOutput?.isDepthDataDeliveryEnabled = (self.photoOutput?.isDepthDataDeliverySupported)!
        } else {
            self.setupResult = .configurationFailed
            self.avCaptureSession.commitConfiguration()
            return
        }
        
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32BGRA)]
        
        if avCaptureSession.canAddOutput(videoDataOutput) {
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.setSampleBufferDelegate(delegate, queue: videoDataOutputQueue)
            avCaptureSession.addOutput(videoDataOutput)
        } else {
            print("Could not add metadata output to the session")
            setupResult = .configurationFailed
            avCaptureSession.commitConfiguration()
            return
        }
        
        avCaptureSession.commitConfiguration()
    }
    
    func addObservers() {
        /*
         Observe the previewView's regionOfInterest to update the AVCaptureMetadataOutput's
         rectOfInterest when the user finishes resizing the region of interest.
         */
        NotificationCenter.default.addObserver(self, selector: #selector(sessionRuntimeError), name: Notification.Name("AVCaptureSessionRuntimeErrorNotification"), object: avCaptureSession)
        
        /*
         A session can only run when the app is full screen. It will be interrupted
         in a multi-app layout, introduced in iOS 9, see also the documentation of
         AVCaptureSessionInterruptionReason. Add observers to handle these session
         interruptions and show a preview is paused message. See the documentation
         of AVCaptureSessionWasInterruptedNotification for other interruption reasons.
         */
        NotificationCenter.default.addObserver(self, selector: #selector(sessionWasInterrupted), name: Notification.Name("AVCaptureSessionWasInterruptedNotification"), object: avCaptureSession)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionInterruptionEnded), name: Notification.Name("AVCaptureSessionInterruptionEndedNotification"), object: avCaptureSession)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func subjectAreaDidChange(notification: NSNotification) {
        
    }
    
    @objc func sessionRuntimeError(notification: NSNotification) {
        
    }
    
    @objc func sessionWasInterrupted(notification: NSNotification) {
        
    }
    
    @objc func sessionInterruptionEnded(notification: NSNotification) {
    }

    func enableContinuousAutoExposure() {
        performConfigurationOnCurrentCameraDevice { (currentDevice) -> Void in
            if currentDevice.isExposureModeSupported(.continuousAutoExposure) {
                currentDevice.exposureMode = .continuousAutoExposure
            }
        }
    }
    
    func performConfiguration(block: @escaping (() -> Void)) {
        sessionQueue.async() { () -> Void in
            block()
        }
    }
    
    func performConfigurationOnCurrentCameraDevice(block: @escaping ((_ currentDevice:AVCaptureDevice) -> Void)) {
        if let currentDevice = self.currentCameraDevice {
            performConfiguration { () -> Void in
                do {
                    try currentDevice.lockForConfiguration()
                    block(currentDevice)
                    currentDevice.unlockForConfiguration()
                }
                catch {}
            }
        }
    }
}
