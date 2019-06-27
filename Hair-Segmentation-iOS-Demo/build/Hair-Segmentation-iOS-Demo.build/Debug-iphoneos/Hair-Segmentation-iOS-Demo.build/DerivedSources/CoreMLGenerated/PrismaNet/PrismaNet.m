//
// PrismaNet.m
//
// This file was automatically generated and should not be edited.
//

#import "PrismaNet.h"

@implementation PrismaNetInput

- (instancetype)initWithInput:(CVPixelBufferRef)input {
    if (self) {
        _input = input;
    }
    return self;
}

- (NSSet<NSString *> *)featureNames {
    return [NSSet setWithArray:@[@"input"]];
}

- (nullable MLFeatureValue *)featureValueForName:(NSString *)featureName {
    if ([featureName isEqualToString:@"input"]) {
        return [MLFeatureValue featureValueWithPixelBuffer:_input];
    }
    return nil;
}

@end

@implementation PrismaNetOutput

- (instancetype)initWithOutput:(MLMultiArray *)output {
    if (self) {
        _output = output;
    }
    return self;
}

- (NSSet<NSString *> *)featureNames {
    return [NSSet setWithArray:@[@"output"]];
}

- (nullable MLFeatureValue *)featureValueForName:(NSString *)featureName {
    if ([featureName isEqualToString:@"output"]) {
        return [MLFeatureValue featureValueWithMultiArray:_output];
    }
    return nil;
}

@end

@implementation PrismaNet

+ (NSURL *)urlOfModelInThisBundle {
    NSString *assetPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"PrismaNet" ofType:@"mlmodelc"];
    return [NSURL fileURLWithPath:assetPath];
}

- (nullable instancetype)init {
        return [self initWithContentsOfURL:self.class.urlOfModelInThisBundle error:nil];
}

- (nullable instancetype)initWithContentsOfURL:(NSURL *)url error:(NSError * _Nullable * _Nullable)error {
    self = [super init];
    if (!self) { return nil; }
    _model = [MLModel modelWithContentsOfURL:url error:error];
    if (_model == nil) { return nil; }
    return self;
}

- (nullable instancetype)initWithConfiguration:(MLModelConfiguration *)configuration error:(NSError * _Nullable * _Nullable)error {
        return [self initWithContentsOfURL:self.class.urlOfModelInThisBundle configuration:configuration error:error];
}

- (nullable instancetype)initWithContentsOfURL:(NSURL *)url configuration:(MLModelConfiguration *)configuration error:(NSError * _Nullable * _Nullable)error {
    self = [super init];
    if (!self) { return nil; }
    _model = [MLModel modelWithContentsOfURL:url configuration:configuration error:error];
    if (_model == nil) { return nil; }
    return self;
}

- (nullable PrismaNetOutput *)predictionFromFeatures:(PrismaNetInput *)input error:(NSError * _Nullable * _Nullable)error {
    return [self predictionFromFeatures:input options:[[MLPredictionOptions alloc] init] error:error];
}

- (nullable PrismaNetOutput *)predictionFromFeatures:(PrismaNetInput *)input options:(MLPredictionOptions *)options error:(NSError * _Nullable * _Nullable)error {
    id<MLFeatureProvider> outFeatures = [_model predictionFromFeatures:input options:options error:error];
    return [[PrismaNetOutput alloc] initWithOutput:[outFeatures featureValueForName:@"output"].multiArrayValue];
}

- (nullable PrismaNetOutput *)predictionFromInput:(CVPixelBufferRef)input error:(NSError * _Nullable * _Nullable)error {
    PrismaNetInput *input_ = [[PrismaNetInput alloc] initWithInput:input];
    return [self predictionFromFeatures:input_ error:error];
}

- (nullable NSArray<PrismaNetOutput *> *)predictionsFromInputs:(NSArray<PrismaNetInput*> *)inputArray options:(MLPredictionOptions *)options error:(NSError * _Nullable * _Nullable)error {
    id<MLBatchProvider> inBatch = [[MLArrayBatchProvider alloc] initWithFeatureProviderArray:inputArray];
    id<MLBatchProvider> outBatch = [_model predictionsFromBatch:inBatch options:options error:error];
    NSMutableArray<PrismaNetOutput*> *results = [NSMutableArray arrayWithCapacity:(NSUInteger)outBatch.count];
    for (NSInteger i = 0; i < outBatch.count; i++) {
        id<MLFeatureProvider> resultProvider = [outBatch featuresAtIndex:i];
        PrismaNetOutput * result = [[PrismaNetOutput alloc] initWithOutput:[resultProvider featureValueForName:@"output"].multiArrayValue];
        [results addObject:result];
    }
    return results;
}

@end
