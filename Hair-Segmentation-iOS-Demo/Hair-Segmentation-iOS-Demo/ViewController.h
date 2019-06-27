//
//  ViewController.h
//  Hair-Segmentation-iOS-Demo
//
//  Created by yuhua.cheng on 2019/6/15.
//  Copyright © 2019 ihandysoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreML/CoreML.h>
#import <Vision/Vision.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> {
    AVCaptureSession *session;
    AVCaptureDevice *device;
    AVCaptureDeviceInput *deviceInput;
    AVCaptureVideoPreviewLayer *previewLayer;
    
    MLModel *model;
    VNCoreMLModel *m;
    VNCoreMLRequest *rq;
    
    NSMutableArray *startTimes;
}

@end

