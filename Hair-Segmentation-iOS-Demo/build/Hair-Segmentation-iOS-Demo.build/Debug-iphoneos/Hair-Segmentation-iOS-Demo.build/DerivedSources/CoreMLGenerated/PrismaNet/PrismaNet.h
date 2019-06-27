//
// PrismaNet.h
//
// This file was automatically generated and should not be edited.
//

#import <Foundation/Foundation.h>
#import <CoreML/CoreML.h>
#include <stdint.h>

NS_ASSUME_NONNULL_BEGIN


/// Model Prediction Input Type
API_AVAILABLE(macos(10.13), ios(11.0), watchos(4.0), tvos(11.0)) __attribute__((visibility("hidden")))
@interface PrismaNetInput : NSObject<MLFeatureProvider>

/// input as color (kCVPixelFormatType_32BGRA) image buffer, 256 pixels wide by 256 pixels high
@property (readwrite, nonatomic) CVPixelBufferRef input;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithInput:(CVPixelBufferRef)input;
@end


/// Model Prediction Output Type
API_AVAILABLE(macos(10.13), ios(11.0), watchos(4.0), tvos(11.0)) __attribute__((visibility("hidden")))
@interface PrismaNetOutput : NSObject<MLFeatureProvider>

/// output as 1 x 256 x 256 3-dimensional array of doubles
@property (readwrite, nonatomic, strong) MLMultiArray * output;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithOutput:(MLMultiArray *)output;
@end


/// Class for model loading and prediction
API_AVAILABLE(macos(10.13), ios(11.0), watchos(4.0), tvos(11.0)) __attribute__((visibility("hidden")))
@interface PrismaNet : NSObject
@property (readonly, nonatomic, nullable) MLModel * model;
- (nullable instancetype)init;
- (nullable instancetype)initWithContentsOfURL:(NSURL *)url error:(NSError * _Nullable * _Nullable)error;
- (nullable instancetype)initWithConfiguration:(MLModelConfiguration *)configuration error:(NSError * _Nullable * _Nullable)error API_AVAILABLE(macos(10.14), ios(12.0), watchos(5.0), tvos(12.0)) __attribute__((visibility("hidden")));
- (nullable instancetype)initWithContentsOfURL:(NSURL *)url configuration:(MLModelConfiguration *)configuration error:(NSError * _Nullable * _Nullable)error API_AVAILABLE(macos(10.14), ios(12.0), watchos(5.0), tvos(12.0)) __attribute__((visibility("hidden")));

/**
    Make a prediction using the standard interface
    @param input an instance of PrismaNetInput to predict from
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the prediction as PrismaNetOutput
*/
- (nullable PrismaNetOutput *)predictionFromFeatures:(PrismaNetInput *)input error:(NSError * _Nullable * _Nullable)error;

/**
    Make a prediction using the standard interface
    @param input an instance of PrismaNetInput to predict from
    @param options prediction options
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the prediction as PrismaNetOutput
*/
- (nullable PrismaNetOutput *)predictionFromFeatures:(PrismaNetInput *)input options:(MLPredictionOptions *)options error:(NSError * _Nullable * _Nullable)error;

/**
    Make a prediction using the convenience interface
    @param input as color (kCVPixelFormatType_32BGRA) image buffer, 256 pixels wide by 256 pixels high:
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the prediction as PrismaNetOutput
*/
- (nullable PrismaNetOutput *)predictionFromInput:(CVPixelBufferRef)input error:(NSError * _Nullable * _Nullable)error;

/**
    Batch prediction
    @param inputArray array of PrismaNetInput instances to obtain predictions from
    @param options prediction options
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the predictions as NSArray<PrismaNetOutput *>
*/
- (nullable NSArray<PrismaNetOutput *> *)predictionsFromInputs:(NSArray<PrismaNetInput*> *)inputArray options:(MLPredictionOptions *)options error:(NSError * _Nullable * _Nullable)error API_AVAILABLE(macos(10.14), ios(12.0), watchos(5.0), tvos(12.0)) __attribute__((visibility("hidden")));
@end

NS_ASSUME_NONNULL_END
