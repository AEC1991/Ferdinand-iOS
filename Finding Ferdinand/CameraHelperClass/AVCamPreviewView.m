//
//  AVCamPreviewView.m
//  Remedy
//
//  Created by Alexander Berezovskyy on 06.10.17.
//  Copyright © 2017 Alexander Berezovskyy. All rights reserved.
//

@import AVFoundation;

#import "AVCamPreviewView.h"

@implementation AVCamPreviewView

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureVideoPreviewLayer *)videoPreviewLayer
{
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (AVCaptureSession *)session
{
    return self.videoPreviewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session
{
    self.videoPreviewLayer.session = session;
}

@end
