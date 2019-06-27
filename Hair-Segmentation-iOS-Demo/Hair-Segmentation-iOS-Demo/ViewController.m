//
//  ViewController.m
//  Hair-Segmentation-iOS-Demo
//
//  Created by yuhua.cheng on 2019/6/15.
//  Copyright © 2019 ihandysoft. All rights reserved.
//

#import "ViewController.h"
#import "PrismaNet.h"

@interface ViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIImage *image = [UIImage imageNamed:@"test2.jpg"];
    CGImageRef cgImageRef = [image CGImage];
    UIImage *result = [[UIImage alloc] init];
    // result = [self predictionWithModel:[self pixelBufferFromCGImage:cgImageRef]];
    result = [self predictionWithVision:image];
    UIImage *merged = [self mergeMask:result WithImage:image WithSize:256];
    _imageView = [[UIImageView alloc] init];
    _imageView.frame = CGRectMake(0,0, image.size.width, image.size.height);
    // _imageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.view addSubview:_imageView];
    [_imageView setImage:merged];
}

- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image{
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CGFloat frameWidth = CGImageGetWidth(image);
    CGFloat frameHeight = CGImageGetHeight(image);
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          frameWidth,
                                          frameHeight,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 frameWidth,
                                                 frameHeight,
                                                 8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),
                                                 rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0,
                                           0,
                                           frameWidth,
                                           frameHeight),
                       image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (UIImage *)predictionWithVision:(UIImage *)image {
    NSError *error = nil;
    PrismaNet* coremlModel = [[PrismaNet alloc] init];
    __block UIImage *result = nil;
    VNCoreMLModel *visionModel = [VNCoreMLModel modelForMLModel:coremlModel.model error:&error];
    CIImage *convertImage = [[CIImage alloc] initWithImage:image];
    VNImageRequestHandler *requestHandler = [[VNImageRequestHandler alloc] initWithCIImage:convertImage options:@{}];
    VNRequestCompletionHandler completionHandler = ^(VNRequest *request, NSError *error) {
        NSArray *observations = request.results;
        for (VNCoreMLFeatureValueObservation *observation  in observations) {
            result = [self imageFromMultiArray:observation.featureValue.multiArrayValue];
           /*
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_imageView setImage:image];
            });
            */
        }
    };
    
    VNCoreMLRequest *detectRequest = [[VNCoreMLRequest alloc] initWithModel:visionModel completionHandler:completionHandler];
    // 执行
    [requestHandler performRequests:@[detectRequest] error:&error];
    if (error) {
        NSLog(@"error---:%@", error.localizedDescription);
    }
    return result;
}
- (UIImage *)predictionWithModel:(CVPixelBufferRef )buffer
{
    PrismaNet* model = [[PrismaNet alloc] init];
    
    NSError *predictionError = nil;
    PrismaNetOutput *modelOutput = [model predictionFromInput:buffer error:&predictionError];
    if (predictionError) {
        NSLog(@"error----:%@", predictionError.localizedDescription);
        return nil;
    } else {
        return [self imageFromMultiArray:modelOutput.output];;
    }
}

- (UIImage *)imageFromMultiArray:(MLMultiArray *)multiArray {
    
    int channels = multiArray.shape[0].intValue;
    int height = multiArray.shape[1].intValue;
    int width = multiArray.shape[2].intValue;
    
    int cStride = multiArray.strides[0].intValue;
    int hStride = multiArray.strides[1].intValue;
    int wStride = multiArray.strides[2].intValue;
    
    double *pointer = (double*) multiArray.dataPointer;
    
    // Holds the mask image
    uint8_t *bytes = (uint8_t*) malloc(width * height * 4);
    
    for (int c = 0; c < channels; c++) {
        for (int h = 0; h < height; h++) {
            for (int w = 0; w < width; w++) {
                double sample = pointer[h * hStride + w * wStride + c * cStride];
                int i = c*cStride + h*hStride + w*wStride;
                bytes[i * 4 + 0] = 0;
                bytes[i * 4 + 1] = sample*255;
                bytes[i * 4 + 2] = 0;
                bytes[i * 4 + 3] = 50;
            }
        }
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(bytes, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast);
    CFRelease(colorSpace);
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:0 orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    
    /*
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_imageView setImage:image];
    });
    */
    
    free(bytes);
    
    return image;
}

- (UIImage *)mergeMask:(UIImage *)mask WithImage: (UIImage *)image WithSize: (NSInteger)size {
    
    CGSize imageSize = CGSizeMake(size, size);
    UIGraphicsBeginImageContext(imageSize);
    CGRect imageFrame = CGRectMake(0, 0, size, size);
    
    [image drawInRect:imageFrame];
    CGRect maskFrame = CGRectMake(0, 0, size, size);
    [mask drawInRect:maskFrame];
    UIImage *result =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
    
}
#pragma mark -
#pragma mark UIImagePickerControllerDelegate


#pragma mark -
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

/*
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVImageBufferRef cvImage = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:cvImage];
    [self labelImage: ciImage];
}
*/
@end
