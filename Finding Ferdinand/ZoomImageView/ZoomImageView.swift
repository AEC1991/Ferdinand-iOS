// ZoomImageView.swift
//
// Copyright (c) 2016 muukii
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

open class ZoomImageView : UIScrollView, UIScrollViewDelegate {
    
    public enum ZoomMode {
        case fit
        case fill
    }
    
    // MARK: - Properties
    
    private let imageView = UIImageView()
    var innerPointArray : [CGPoint]! = []
    var innerPointsView : [MarkerView]! = []
    var outerPointArray : [CGPoint]! = []
    var outerPointsView : [MarkerView]! = []
    var convertRate : CGPoint?
    var mContext: CGContext?
    var mLipColor: CGColor?
    var mOriginImage : UIImage?
    var mOldZoomScale : CGFloat = 0
    let DefRadius : CGFloat = 16.0
    var mOpacity : CGFloat = 1
    
    
    public var zoomMode: ZoomMode = .fill {
        didSet {
            updateImageView()
        }
    }
    
    open var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            let oldImage = imageView.image
            imageView.image = newValue
            
            if oldImage?.size != newValue?.size {
                oldSize = nil
                updateImageView()
            }
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        return imageView.intrinsicContentSize
    }
    
    private var oldSize: CGSize?
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public init(image: UIImage) {
        super.init(frame: CGRect.zero)
        self.image = image
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Functions
    
    open func scrollToCenter() {
        
        let centerOffset = CGPoint(
            x: (contentSize.width / 2) - (bounds.width / 2),
            y: (contentSize.height / 2) - (bounds.height / 2)
        )
        
        contentOffset = centerOffset
    }
    
    open func setup() {
        
        #if swift(>=3.2)
            if #available(iOS 11, *) {
                contentInsetAdjustmentBehavior = .never
            }
        #endif
        
        backgroundColor = UIColor.clear
        delegate = self
        imageView.contentMode = .scaleAspectFill
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        decelerationRate = UIScrollViewDecelerationRateFast
        addSubview(imageView)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGesture)
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
    
    open override func layoutSubviews() {
        
        super.layoutSubviews()
        
        if imageView.image != nil && oldSize != bounds.size {
            
            updateImageView()
            oldSize = bounds.size
        }
        
        if imageView.frame.width <= bounds.width {
            imageView.center.x = bounds.width * 0.5
        }
        
        if imageView.frame.height <= bounds.height {
            imageView.center.y = bounds.height * 0.5
        }
        
        recalcPointArray()
    }
    
    open override func updateConstraints() {
        super.updateConstraints()
        updateImageView()
    }
    
    private func updateImageView() {
        
        func fitSize(aspectRatio: CGSize, boundingSize: CGSize) -> CGSize {
            
            let widthRatio = (boundingSize.width / aspectRatio.width)
            let heightRatio = (boundingSize.height / aspectRatio.height)
            
            var boundingSize = boundingSize
            
            if widthRatio < heightRatio {
                boundingSize.height = boundingSize.width / aspectRatio.width * aspectRatio.height
            }
            else if (heightRatio < widthRatio) {
                boundingSize.width = boundingSize.height / aspectRatio.height * aspectRatio.width
            }
            return CGSize(width: ceil(boundingSize.width), height: ceil(boundingSize.height))
        }
        
        func fillSize(aspectRatio: CGSize, minimumSize: CGSize) -> CGSize {
            let widthRatio = (minimumSize.width / aspectRatio.width)
            let heightRatio = (minimumSize.height / aspectRatio.height)
            
            var minimumSize = minimumSize
            
            if widthRatio > heightRatio {
                minimumSize.height = minimumSize.width / aspectRatio.width * aspectRatio.height
            }
            else if (heightRatio > widthRatio) {
                minimumSize.width = minimumSize.height / aspectRatio.height * aspectRatio.width
            }
            return CGSize(width: ceil(minimumSize.width), height: ceil(minimumSize.height))
        }
        
        guard let image = imageView.image else { return }
        
        var size: CGSize
        
        switch zoomMode {
        case .fit:
            size = fitSize(aspectRatio: image.size, boundingSize: bounds.size)
        case .fill:
            size = fillSize(aspectRatio: image.size, minimumSize: bounds.size)
        }
        
        size.height = round(size.height)
        size.width = round(size.width)
        
        zoomScale = 1
        mOldZoomScale = 0
        //maximumZoomScale = image.size.width / size.width
        maximumZoomScale = 10
        imageView.bounds.size = size
        contentSize = size
        imageView.center = contentCenter(forBoundingSize: bounds.size, contentSize: contentSize)
    }
    
    @objc private func handleDoubleTap() {
        if self.zoomScale == 1 {
            setZoomScale(max(1, maximumZoomScale / 3), animated: true)
        } else {
            setZoomScale(1, animated: true)
        }
        
        mOldZoomScale = zoomScale
    }
    
    // MARK: - UIScrollViewDelegate
    @objc dynamic public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageView.center = contentCenter(forBoundingSize: bounds.size, contentSize: contentSize)
    }
    
    @objc dynamic public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        
    }
    
    @objc dynamic public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
    }
    
    @objc dynamic public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    @inline(__always)
    private func contentCenter(forBoundingSize boundingSize: CGSize, contentSize: CGSize) -> CGPoint {
        
        /// When the zoom scale changes i.e. the image is zoomed in or out, the hypothetical center
        /// of content view changes too. But the default Apple implementation is keeping the last center
        /// value which doesn't make much sense. If the image ratio is not matching the screen
        /// ratio, there will be some empty space horizontaly or verticaly. This needs to be calculated
        /// so that we can get the correct new center value. When these are added, edges of contentView
        /// are aligned in realtime and always aligned with corners of scrollview.
        let horizontalOffest = (boundingSize.width > contentSize.width) ? ((boundingSize.width - contentSize.width) * 0.5): 0.0
        let verticalOffset = (boundingSize.height > contentSize.height) ? ((boundingSize.height - contentSize.height) * 0.5): 0.0
        
        return CGPoint(x: contentSize.width * 0.5 + horizontalOffest,  y: contentSize.height * 0.5 + verticalOffset)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if mOldZoomScale != zoomScale {
            //print(String(format: "%f", zoomScale))
            mOldZoomScale = zoomScale
            
            for item in innerPointsView {
                item.changeSize(CGSize(width: DefRadius*zoomScale, height: DefRadius*zoomScale))
            }
            
            for item in outerPointsView {
                item.changeSize(CGSize(width: DefRadius*zoomScale, height: DefRadius*zoomScale))
            }
        }
    }
    
    func addControl(in index: Int, in p: CGPoint, action: Selector?) -> MarkerView! {
        var r : CGRect = CGRect()
        r.origin = p
        r.size = CGSize(width: DefRadius, height: DefRadius)
        
        let control : MarkerView = MarkerView(frame: r)
        control.backgroundColor = UIColor.clear
        control.tag = index
        self.addSubview(control)
        
        let rec = UIPanGestureRecognizer(target: self, action: action)
        //control.isUserInteractionEnabled = true
        control.addGestureRecognizer(rec)
        return control
    }
    
    @objc func dragOuterMarker(recognizer: UIPanGestureRecognizer) {
        dragMarker(recognizer, false)
    }
    
    @objc func dragInnerMarker(recognizer: UIPanGestureRecognizer) {
        dragMarker(recognizer, true)
    }
    
    func dragMarker(_ recognizer: UIPanGestureRecognizer, _ isInner: Bool) {
        let view : UIView = recognizer.view!
        
        let translation = recognizer.translation(in: self)
        var newCenter = view.center
        newCenter.x += translation.x
        newCenter.y += translation.y
        view.center = newCenter
        recognizer.setTranslation(CGPoint.zero, in: self)
        
        let realCenter : CGPoint = CGPoint(x: newCenter.x / zoomScale - imageView.frame.origin.x, y: newCenter.y / zoomScale - imageView.frame.origin.y)
        let tag = view.tag
        
        let pointer : CGPoint=devicePoint2UserPoint(realCenter)!
        if isInner == true {
            innerPointArray[tag] = pointer
        } else {
            outerPointArray[tag] = pointer
        }
        
        redrawImages()
        //print(String(format: "%f, %f- %f, %f", imageView.frame.origin.x, imageView.frame.origin.y, realCenter.x, realCenter.y))
    }
    
    public func initInnerAndOuterPoints(_ innerPointArray: [CGPoint]!, _ outerPointArray: [CGPoint]!, _ convertRate: CGPoint, _ image: UIImage) {
        self.innerPointArray.removeAll()
        for item in innerPointArray {
            self.innerPointArray.append(item)
        }
        
        self.outerPointArray.removeAll()
        for item in outerPointArray {
            self.outerPointArray.append(item)
        }
        
        self.convertRate = convertRate
        self.mOriginImage = image
    }
    
    public func initVars() {
        outerPointsView.removeAll()
        for i in 0...outerPointArray.count - 1 {
            let point = userPoint2DevicePoint(outerPointArray[i])
            let control = addControl(in: i, in: point!, action: #selector(dragOuterMarker))
            
            outerPointsView!.append(control!)
        }
        
        innerPointsView.removeAll()
        for i in 0...innerPointArray.count - 1 {
            let point = userPoint2DevicePoint(innerPointArray[i])
            let control = addControl(in: i, in: point!, action: #selector(dragInnerMarker))
            
            innerPointsView!.append(control!)
        }
        
        setZoomScale(zoomScale, animated: false)
    }
    
    public func clearVars() {
        zoomScale = 1
        
        for item in outerPointsView {
            item.removeFromSuperview()
        }
        outerPointsView.removeAll()
    
        for item in innerPointsView {
            item.removeFromSuperview()
        }
        innerPointsView.removeAll()
    }
    
    public func recalcPointArray() {
        //print(String(format: "recalcPointArray: %f, %f", imageView.frame.origin.x, imageView.frame.origin.y))
        
        if (outerPointArray.count > 0) {
            var index : Int = 0
            for item in outerPointArray {
                let point = userPoint2DevicePoint(item)
                let newCenter : CGPoint = CGPoint(x: imageView.frame.origin.x + point!.x * zoomScale,
                                                  y: imageView.frame.origin.y + point!.y * zoomScale)
                
                if outerPointsView.count > index {
                    outerPointsView[index].center = newCenter
                }
                index = index + 1
            }
        }
        
        if (innerPointArray.count > 0) {
            var index : Int = 0
            for item in innerPointArray {
                let point = userPoint2DevicePoint(item)
                let newCenter : CGPoint = CGPoint(x: imageView.frame.origin.x + point!.x * zoomScale,
                                                  y: imageView.frame.origin.y + point!.y * zoomScale)
                
                if innerPointsView.count > index {
                    innerPointsView[index].center = newCenter
                }
                
                index = index + 1
            }
        }
    }
    
    public func redrawImages(_ image: UIImage? = nil) {
        if (self.mOriginImage == nil) {
            return
        }
        
        let orgImage: UIImage? = image != nil ? image:self.mOriginImage
        let maskRect = CGRect(x: 0, y: 0, width: (orgImage?.size.width)!, height: (orgImage?.size.height)!)
        
        UIGraphicsBeginImageContextWithOptions((orgImage?.size)!, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        mContext = context
        
        context?.clear(maskRect)
        // draw the image
        orgImage?.draw(in: maskRect)
        
        context?.translateBy(x: 0, y: (orgImage?.size.height)!)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        if image != nil {
            initVars()
        }
        
        fillRegion(context, outerPointArray, mLipColor!, CGBlendMode.copy, false)
        fillRegion(context, innerPointArray, mLipColor!, CGBlendMode.clear, false)
        
        // get the final image
        let lipImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // end drawing context
        UIGraphicsEndImageContext()
        
        if lipImage != nil {
            self.image = combineFaceLipImage((orgImage)!, lipImage!)
        }
    }
    
    public func setLipColor(_ lipColor: CGColor? = nil) {
        self.mLipColor = lipColor
    }
    
    func fillRegion(_ context: CGContext?, _ arrayPoints: [CGPoint]!, _ color: CGColor, _ blendMode: CGBlendMode, _ onlyLine: Bool=true) {
        context?.saveGState()
        context?.setBlendMode(blendMode)
        
        for i in 0...arrayPoints.count - 1 { // last point is 0,0
            let point = arrayPoints[i]
            if i == 0 {
                context?.move(to: point)
            } else {
                context?.addLine(to: point)
            }
            
            //context?.fillEllipse(in: CGRect(x: point.x, y: point.y, width: 10, height: 10))
        }
        
        context?.closePath()
        if onlyLine == false {
            let newColor = color.copy(alpha: mOpacity)
            context?.setFillColor(newColor!)
        } else {
            context?.setStrokeColor(color)
            context?.strokePath()
        }
        
        context?.fillPath()
        context?.saveGState()
    }
    
    func combineFaceLipImage(_ faceImage: UIImage, _ lipImage: UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(faceImage.size, false, 0.0)
        faceImage.draw(in: CGRect(x: 0, y: 0, width: faceImage.size.width, height: faceImage.size.height))
        lipImage.draw(in: CGRect(x: 0, y: 0, width: lipImage.size.width, height: lipImage.size.height))
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage
    }
    
    public func getImageViewSize() -> CGSize {
        return imageView.frame.size;
    }
    
    public func devicePoint2UserPoint(_ devPoint: CGPoint) -> CGPoint? {
        if mContext == nil || self.convertRate ==  nil {
            return nil;
        }
        
        let newDevPoint = CGPoint(x: devPoint.x / (self.convertRate?.x)!,
                                  y: devPoint.y / (self.convertRate?.y)!)
        let userPoint = (self.mContext?.convertToUserSpace(newDevPoint))!
        
        return userPoint
    }
    
    public func userPoint2DevicePoint(_ userPoint: CGPoint) -> CGPoint? {
        if mContext == nil || self.convertRate ==  nil {
            return nil;
        }
        
        let devPoint = (self.mContext?.convertToDeviceSpace(userPoint))!
        let point = CGPoint(x: devPoint.x * (self.convertRate?.x)!,
                            y: devPoint.y * (self.convertRate?.y)!)
        
        return point
    }
    
    public func showPointViews(_ bShow: Bool) {
        for item in innerPointsView {
            item.isHidden = !bShow
        }
        
        for item in outerPointsView {
            item.isHidden = !bShow
        }
    }
    
    public func setLipOpacity(_ opacity: CGFloat) {
        mOpacity = opacity
    }
}

