//
//  IFVideoEncoder.m
//  IFVideoPickerControllerDemo
//
//  Created by Min Kim on 3/27/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import "IFVideoEncoder.h"

@interface IFVideoEncoder () {
}

- (void)setupWithCodec:(NSString *)codec
            dimensions:(CMVideoDimensions)dimensions
               bitRate:(CGFloat)bitRate
           maxKeyFrame:(CGFloat)maxKeyFrame;
@end

@implementation IFVideoEncoder

@synthesize assetWriterInput;
@synthesize dimensions;
@synthesize bitRate;
@synthesize maxKeyFrame;

+ (IFVideoEncoder *)createH264VideoWithDimensions:(CMVideoDimensions)dimensions
                                          bitRate:(CGFloat)bitRate
                                      maxKeyFrame:(CGFloat)maxKeyFrame {
  IFVideoEncoder *encoder = [[[IFVideoEncoder alloc] init] autorelease];
  [encoder setupWithCodec:AVVideoCodecH264
               dimensions:dimensions
                  bitRate:bitRate
               maxKeyFrame:maxKeyFrame];
  return encoder;
}

- (void)dealloc {
  if (assetWriterInput != nil) {
    [assetWriterInput release];
  }
  
  [super dealloc];
}

- (void)setupWithCodec:(NSString *)codec
            dimensions:(CMVideoDimensions)aDimensions
               bitRate:(CGFloat)aBitRate
           maxKeyFrame:(CGFloat)aMaxKeyFrame {
  NSDictionary *videoCompressionSettings =
      [NSDictionary dictionaryWithObjectsAndKeys:codec, AVVideoCodecKey,
          [NSNumber numberWithInteger:aDimensions.width], AVVideoWidthKey,
          [NSNumber numberWithInteger:aDimensions.height], AVVideoHeightKey,
          [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInteger:aBitRate], AVVideoAverageBitRateKey,
            [NSNumber numberWithInteger:aMaxKeyFrame], AVVideoMaxKeyFrameIntervalKey,
           nil], AVVideoCompressionPropertiesKey,
       nil];

  AVAssetWriterInput *newWriterInput =
      [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo
                                     outputSettings:videoCompressionSettings];
  newWriterInput.expectsMediaDataInRealTime = YES;
  // newWriterInput.transform = CGAffineTransformMakeRotation(M_PI/2);
  // newWriterInput.transform = [self transformFromCurrentVideoOrientationToOrientation:self.referenceOrientation];
  self.assetWriterInput = newWriterInput;
  self.dimensions = aDimensions;
  self.maxKeyFrame = aMaxKeyFrame;
  self.bitRate = aBitRate;
  [newWriterInput release];
}

@end
