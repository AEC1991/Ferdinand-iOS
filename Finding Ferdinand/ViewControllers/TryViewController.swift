//
//  TryViewController.swift
//  Ferdinand
//
//  Created by iOS Developer on 3/5/18.
//  Copyright © 2018 Hamal Labs. All rights reserved.
//

import UIKit
import Photos
import GLKit
import AVKit
import CoreMotion
import CoreData
import Vision
import FBSDKCoreKit
import FBSDKShareKit
import Social
import UICollectionViewGallery


class TryViewController: BaseViewController {
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var colorCollection: UICollectionView!
    @IBOutlet weak var btnShot: UIButton!
    @IBOutlet weak var selectView: CircleView!
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var imgScrollView: ZoomImageView!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var finalView: UIView!
    @IBOutlet weak var finalImageView: UIImageView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnCart: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var toolsPane: UIView!
    @IBOutlet weak var tapView: UIView!
    @IBOutlet weak var bottomPane: UIView!
    @IBOutlet weak var statusPane: UIView!
    
    var colorSets = [ColorSet]()
    var captureImage:UIImage!
    // VNRequest: Either Retangles or Landmarks
    var faceDetectionRequest: VNRequest!
    var selectedIndex: Int = 0
    var prefixCount: Int = 1
    var isEditable: Bool = false
    var mActiveStatus = 0
    var foundLip : Bool = false
    var initialScrollDone : Bool = false
    var initialFirstOpen : Bool = true
    var timer = Timer()
    
    private var requests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad(showCartButton: true)
        
        // Set up Vision Request
        faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: self.handleFaceLandmarks) // Default
        setupVision()

        previewView.initSetupResult()
        previewView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (kSelectIndex != -1) {
            selectedIndex = kSelectIndex;
            kSelectIndex = -1;
        }
        selectColorSet(selectedIndex, true)
        
        if (initialFirstOpen == true) {
            initialFirstOpen = false
            
            statusPane.isHidden = false
            // start the timer
            timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)

            changeActiveStatus(mActiveStatus)
            
            btnShot.backgroundColor = .clear
            btnShot.makeCircular()
            btnShot.layer.borderWidth = 4
            btnShot.layer.borderColor = UIColor(rgb:0xd9d9d9).cgColor
            
            let tapShot = UITapGestureRecognizer(target: self, action: #selector(self.shotTapped(_:)))
            selectView.addGestureRecognizer(tapShot)
        } else {
            if (mActiveStatus == 0) {
                previewView.startSessionQueue();
            }
        }
    }
    
    @objc func timerAction() {
        statusPane.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureGalleryAndTapSize()
        
        colorSets = MainViewController.colorSets
        self.colorCollection.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        previewView.stopSessionQueue()
        
        if (isEditable == true) {
            btnEdit.sendActions(for: .touchUpInside)
        }
    }
    
    
    @objc func shotTapped(_ sender:AnyObject) {
        if (mActiveStatus == 0) {
            if (previewView.lipColor == nil) {
                Tools.showAlert(self, "Message", "You must select lip color.")
                return
            }
            
            if (self.foundLip == false) {
                Tools.showAlert(self, "Message", "Lip did not captured yet.")
                return
            }
            
            changeActiveStatus(1)
        }
    }
    
    func doShareAction() {
        //let text = "\(self.colorSets[self.selectedIndex - self.mPrefixColorCount].name), \(self.filterLabel.text!)"
        // text to share
        let text = "http://bit.ly/findingferdinand"
        let image = self.finalImageView.image
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let textAction = UIAlertAction(title: "Text", style: UIAlertActionStyle.default) { _ in
            
            // set up activity view controller
            let textToShare = [ text, image! ] as [Any]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            // exclude some activity types from the list (optional)
            activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
            
            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
        }
        let whatsappAction = UIAlertAction(title: "Whatsapp", style: UIAlertActionStyle.default) { _ in
            WhatsappManager.sharedManager.postImageWithCaption(image: image!, caption: text, view: self.view)
        }
        let facebookAction = UIAlertAction(title: "Facebook", style: UIAlertActionStyle.default) { _ in
            let photo = FBSDKSharePhoto()
            photo.image = image
            photo.isUserGenerated = true
            let content = FBSDKSharePhotoContent()
            content.photos = [photo]
            
            FBSDKShareDialog.show(from: self, with: content, delegate: self)
        }
        let instagramAction = UIAlertAction(title: "Instagram", style: UIAlertActionStyle.default) { _ in
            InstagramManager.sharedManager.postImageWithCaption(image: image!, caption: "Test Instagram", view: self.view)
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(textAction)
        alert.addAction(whatsappAction)
        alert.addAction(facebookAction)
        alert.addAction(instagramAction)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onDownloadBtnEvent(_ sender: Any) {
        if (mActiveStatus == 0) {
            Tools.showAlert(self, "Error!", "Please take a photo.")
            return;
        }
        
        if (isEditable == true) {
            Tools.showAlert(self, "Error!", "Now you are in Edit mode.")
            return
        }
        
        makeFinalImage(imgScrollView.image!)
        UIImageWriteToSavedPhotosAlbum(self.finalImageView.image!, nil, nil, nil);
        Tools.showAlert(self, "Saved!", "You can check the image in your photo gallery.")
    }
    
    @IBAction func onShareBtnEvent(_ sender: Any) {
        if (mActiveStatus == 0) {
            Tools.showAlert(self, "Error!", "Please take a photo.")
            return;
        }
        
        if (isEditable == true) {
            Tools.showAlert(self, "Error!", "Now you are in Edit mode.")
            return
        }
                
        makeFinalImage(imgScrollView.image!)
        self.doShareAction()
    }
    
    @IBAction func onCartBtnEvent(_ sender: Any) {
        if (mActiveStatus == 0) {
            Tools.showAlert(self, "Error!", "Please take a photo.")
            return;
        }
        
        if (isEditable == true) {
            Tools.showAlert(self, "Error!", "Now you are in Edit mode.")
            return
        }
        
        let colorSet = self.colorSets[selectedIndex]
        self.alertAndBuy(colorSet)
    }
    
    @IBAction func onEditBtnEvent(_ sender: Any) {
        if (mActiveStatus == 0) {
            Tools.showAlert(self, "Error!", "Please take a photo.")
            return;
        }
        
        isEditable = !isEditable
        imgScrollView.showPointViews(isEditable)
        
        if (isEditable == false) {
            imgScrollView.setZoomScale(1, animated: false)
            imgScrollView.redrawImages()
        }
    }
    
    @IBAction func onCloseBtnEvent(_ sender: Any) {
        if (mActiveStatus > 0) {
            changeActiveStatus(0)
        }
    }
    
    @IBAction func onFavBtnEvent(_ sender: Any) {
        if (selectedIndex >= colorSets.count) {
            return
        }
        
        let colorSet = colorSets[selectedIndex]
        
        colorSet.favourite = !colorSet.favourite
        favButton.setImage(UIImage(named: colorSet.favourite ? "icon_heart_on":"icon_heart_off"), for: UIControlState.normal)
        
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func changeActiveStatus(_ status: Int) {
        mActiveStatus = status
        
        if (status == 0) {
            self.previewView.isHidden = false
            self.photoView.isHidden = true
            self.finalView.isHidden = true
            self.toolsPane.isHidden = true
            
            imgScrollView.clearVars()
            
            //favButton.isHidden = true
            btnClose.isHidden = true
            
            previewView.startSessionQueue()
            
            isEditable = false
            return
        }
        
        if (status == 1) {
            self.previewView.isHidden = true
            self.photoView.isHidden = false
            self.finalView.isHidden = true
            self.toolsPane.isHidden = false
            
            self.imgScrollView.image = self.captureImage
            detectLip(faceImg: self.captureImage)
            
            //favButton.isHidden = false
            btnClose.isHidden = false
            btnEdit.isHidden = false
            
            previewView.stopSessionQueue()
            return
        }
        
        if (status == 2) {
            btnEdit.isHidden = true
            return
        }
        
        if (status == 3) {
            self.previewView.isHidden = true
            self.photoView.isHidden = true
            self.finalView.isHidden = false
            
            favButton.isHidden = true
        }
    }
}


extension TryViewController: AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
            
            let exifOrientation = CGImagePropertyOrientation(rawValue: previewView!.exifOrientationFromDeviceOrientation()) else { return }
        var requestOptions: [VNImageOption : Any] = [:]
        
        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics : cameraIntrinsicData]
        }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let originalImage = UIImage(ciImage:ciImage, scale: 1.0, orientation:.downMirrored)
        
        let tempImage = originalImage.rotate(radians: .pi/2)
        let tempSize = tempImage?.size
        let viewSize = self.previewView.frame.size
        
        var cropRect : CGRect = CGRect.zero
        if (tempSize?.width)! <= (tempSize?.height)! {
            let newHeight = (tempSize?.width)! * (viewSize.height / viewSize.width)
            cropRect = CGRect(x: 0, y: ((tempSize?.height)! - newHeight) / 2, width: (tempSize?.width)!, height: newHeight)
        } else {
            let newWidth = (tempSize?.height)! * (viewSize.width / viewSize.height)
            cropRect = CGRect(x: ((tempSize?.width)! - newWidth) / 2, y: 0, width: newWidth, height: (tempSize?.height)!)
        }
        
        self.captureImage = Tools.cropImage(tempImage!, cropRect)
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(requests)
        } catch {
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func detectLip(faceImg:UIImage) {
//        let exifOrientation = CGImagePropertyOrientation(rawValue: exifOrientationFromDeviceOrientation())

        var orientation:Int32 = 0

        // detect image orientation, we need it to be accurate for the face detection to work
        switch faceImg.imageOrientation {
        case .up:
            orientation = 1
        case .right:
            orientation = 6
        case .down:
            orientation = 3
        case .left:
            orientation = 8
        default:
            orientation = 1
        }
        
        // vision
        let faceLandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: self.handleFaceFeatures)
        let requestHandler = VNImageRequestHandler(cgImage: faceImg.cgImage!, orientation: CGImagePropertyOrientation(rawValue: UInt32(orientation))! ,options: [:])
        do {
            try requestHandler.perform([faceLandmarksRequest])
        } catch {
            print(error)
        }
    }
    
    func handleFaceFeatures(request: VNRequest, errror: Error?) {
        guard let observations = request.results as? [VNFaceObservation] else {
            fatalError("unexpected result type!")
        }
        
        for face in observations {
            addFaceLandmarksToImage(face, self.imgScrollView.image!)
            break
        }
    }
    
    func addFaceLandmarksToImage(_ face: VNFaceObservation, _ image:UIImage) {
        // calculate user:device rate radio
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        let userPoint1 = (context?.convertToDeviceSpace(CGPoint(x: image.size.width, y: image.size.height)))!
        //let userPoint2 = (context?.convertToDeviceSpace(CGPoint(x: 0, y: image.size.height)))!
        let userPoint3 = (context?.convertToDeviceSpace(CGPoint(x: image.size.width, y: 0)))!
        //let userPoint4 = (context?.convertToDeviceSpace(CGPoint(x: 0, y: 0)))!
        let radio = CGPoint(x: userPoint1.x / image.size.width, y: userPoint3.y / image.size.height)
        
        UIGraphicsEndImageContext()
        
        
        // draw the face rect
        let w = face.boundingBox.size.width * image.size.width
        let h = face.boundingBox.size.height * image.size.height
        let x = face.boundingBox.origin.x * image.size.width
        let y = face.boundingBox.origin.y * image.size.height
        
        let outerLips = getPointArrayFromLandmarkRegion(face.landmarks?.outerLips, x, y, w, h)
        let innerLips = getPointArrayFromLandmarkRegion(face.landmarks?.innerLips, x, y, w, h)
        
        let imgViewSize = imgScrollView.getImageViewSize()
        let convertRate = CGPoint(x: imgViewSize.width / image.size.width / radio.x,
                                  y: imgViewSize.height / image.size.height / radio.y)
        
        imgScrollView.initInnerAndOuterPoints(innerLips, outerLips, convertRate, image)
        
        imgScrollView.setLipOpacity(0.35)
        imgScrollView.setLipColor(previewView.lipColor.cgColor)
        imgScrollView.redrawImages(image)
        imgScrollView.showPointViews(isEditable)
    }
    
    func getPointArrayFromLandmarkRegion(_ region: VNFaceLandmarkRegion2D?, _ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> [CGPoint]! {
        var pointArray : [CGPoint]! = []
        if let landmark = region {
            for i in 0...landmark.pointCount - 1 {
                let point = landmark.normalizedPoints[i]
                let userPos = CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h)
                
                pointArray.append(userPos)
            }
        }
        
        return pointArray
    }
    
    func makeFinalImage(_ image: UIImage) {
        let maskRect = CGRect(origin: CGPoint.zero, size: finalImageView.frame.size)
        let newImageHeight = maskRect.size.height - 40 - 40
        let newImageWidth = newImageHeight * image.size.width / image.size.height
        let imageRect = CGRect(x: (maskRect.size.width - newImageWidth) / 2, y: 40,
                               width: newImageWidth, height: newImageHeight)
        
        UIGraphicsBeginImageContextWithOptions(self.finalImageView.frame.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        context?.clear(maskRect)
        
        let rectangle = CGRect(origin: CGPoint.zero, size: image.size)
        
        UIColor.white.set()
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.addRect(rectangle)
        context?.drawPath(using: .fillStroke)
        
        // draw the image
        image.draw(in: imageRect)
        
        // draw the logo image
        let imgLogo = UIImage(named: "navigation")
        let imgLogoRect = CGRect(x: (maskRect.size.width - 180) / 2, y: (40 - 18) / 2,
                               width: 180, height: 18)
        imgLogo?.draw(in: imgLogoRect)
        
        UIColor.clear.set()
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineWidth(2.0)
        context?.addRect(imageRect)
        context?.drawPath(using: .fillStroke)
        
        
        //textToImage("FINDING FERDINAND", CGRect(x: 0, y: 0, width: maskRect.size.width, height: 40), UIFont(name: "Oswald", size: 18)!)
        
        textToImage("\(colorSets[selectedIndex].name)" as NSString, CGRect(x: 0, y: maskRect.height - 40, width: maskRect.size.width, height: 40), UIFont(name: "Oswald-Regular", size: 18)!)
        
        
        // get the final image
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // end drawing context
        UIGraphicsEndImageContext()
        
        finalImageView.image = finalImage
    }
    
    func textToImage(_ drawText: NSString, _ drawRect: CGRect, _ textFont: UIFont) {
        let textColor = UIColor.black
        
        let textFontAttributes = [
            NSAttributedStringKey.font: textFont,
            NSAttributedStringKey.foregroundColor: textColor,
            ] as [NSAttributedStringKey : Any]
        
        let textSize = drawText.size(withAttributes: textFontAttributes)
        if textSize.width < drawRect.size.width {
            let textRect = CGRect(x: drawRect.size.width / 2 - textSize.width / 2,
                                  y: drawRect.origin.y + drawRect.size.height / 2 - textSize.height / 2,
                                  width: textSize.width,
                                  height: textSize.height)
            drawText.draw(in: textRect, withAttributes: textFontAttributes)
        } else {
            let textRect = CGRect(origin: CGPoint.zero, size: drawRect.size)
            drawText.draw(in: textRect, withAttributes: textFontAttributes)
        }
    }
}

extension TryViewController {
    func setupVision() {
        self.requests = [faceDetectionRequest]
    }
    
    func handleFaces(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            //perform all the UI updates on the main queue
            guard let results = request.results as? [VNFaceObservation] else { return }
            self.previewView.removeMask()
            for face in results {
                self.previewView.drawFaceboundingBox(face: face)
                break
            }
        }
    }
    
    func handleFaceLandmarks(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            //perform all the UI updates on the main queue
            guard let results = request.results as? [VNFaceObservation] else { return }
            self.previewView.removeMask()
            for face in results {
                self.previewView.drawFaceWithLandmarks(face: face)
                break
            }
            
            self.foundLip = results.count > 0 ? true:false
        }
    }
}

extension TryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func configureGalleryAndTapSize() {
        colorCollection.delegate = self
        colorCollection.dataSource = self
        let width = UIScreen.main.bounds.width / 3
        var height = bottomPane.bounds.height
        if (height > width + 64) {
            height = width + 64
        }
        
        //tapHeightConstraint.constant = height - 64
        //tapView.layoutIfNeeded()
        
        let cellSize = CGSize(width: width, height: height)
        colorCollection.setGallery(withStyle: .horizontal, minLineSpacing: 0, itemSize: cellSize, minScaleFactor:1)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == colorCollection) {
            return colorSets.count + prefixCount * 2
        }
        
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == colorCollection) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
            var index = indexPath.row
            
            if (index < prefixCount || index >= colorSets.count + prefixCount) {
                cell.setColorSet(colorSet: nil)
            } else {
                //print("collectionView: \(index), \(colorSets[index].name)")
                index = index - prefixCount
                cell.setColorSet(colorSet: colorSets[index])
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView == colorCollection) {
            if (indexPath.row == 0 || indexPath.row > colorSets.count) {
                return
            }
            
            selectColorSet(indexPath.row - prefixCount, true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView == colorCollection) {
            let width = UIScreen.main.bounds.width / 3
            var height = bottomPane.bounds.height
            if (height > width + 64) {
                height = width + 64
            }
            
            let cellSize = CGSize(width: width, height: height)
            
            return cellSize
        }
        
        return CGSize(width: 0, height: 0)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("scrollViewDidScroll")
        colorCollection.recenterIfNeeded()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //print("scrollViewDidEndDecelerating")
        if (scrollView == colorCollection) {
            reselectNearItem(scrollView)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //print("scrollViewDidEndDragging")
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !initialScrollDone {
            initialScrollDone = true
            
            if (colorSets.count == 0) {
                return
            }
            
            self.colorCollection.scrollToItem(at: IndexPath(row: colorSets.count-1, section: 0), at: .right, animated: false)
        }
    }
    
    func reselectNearItem(_ scrollView: UIScrollView) {
        let screenSize = UIScreen.main.bounds
        let screenCenterX = screenSize.width / 2
        var selectIndex : IndexPath? = nil
        var selectDistance : CGFloat = 0
        
        for cell in self.colorCollection.visibleCells {
            let indexPath = self.colorCollection.indexPath(for: cell)
            let centerX = cell.frame.origin.x + cell.frame.width / 2  - scrollView.contentOffset.x
            
            if (selectIndex == nil) {
                selectIndex = indexPath
                selectDistance = abs(centerX - screenCenterX)
            } else {
                let distance = abs(centerX - screenCenterX)
                if (distance < selectDistance) {
                    selectIndex = indexPath
                    selectDistance = distance
                }
            }
        }
        
        if (selectIndex != nil) {
            selectColorSet(selectIndex!.row - prefixCount, true)
        }
    }

    func selectColorSet(_ index: Int, _ selectItem: Bool=false) {
        print("selectColorSet: \(index)")
        if (colorSets.count == 0) {
            return
        }
        
        selectedIndex = index
        let colorSet = colorSets[selectedIndex]

        if (selectItem == true) {
            let indexPath = IndexPath(row: index + prefixCount, section: 0)
            colorCollection.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        }
        selectView.backColor = colorSet.uiColor
        previewView.lipColor = colorSet.uiColor

        favButton.setImage(UIImage(named: colorSet.favourite ? "icon_heart_on":"icon_heart_off"), for: UIControlState.normal)

        if (mActiveStatus == 1) {
            imgScrollView.setLipColor(colorSet.uiColor.cgColor)
            imgScrollView.redrawImages()
        }
    }
}

extension TryViewController: FBSDKSharingDelegate {
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        print("didCompleteWithResults")
    }
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        Tools.showAlert(self, "Error", "Please install the Facebook application")
        print("didFailWithError\(error)")
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        print("sharerDidCancel")
    }    
}

extension UIDeviceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeRight
        case .landscapeRight: return .landscapeLeft
        default: return nil
        }
    }
}

extension UIInterfaceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
        default: return nil
        }
    }
}



