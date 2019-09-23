//
//  AVCamPreviewView.h
//  Remedy
//
//  Created by Alexander Berezovskyy on 06.10.17.
//  Copyright © 2017 Alexander Berezovskyy. All rights reserved.
//

@import UIKit;
@import AVFoundation;

@class AVCaptureSession;

@interface AVCamPreviewView : UIView

@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (nonatomic) AVCaptureSession *session;

@end
