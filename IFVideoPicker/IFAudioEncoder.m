//
//  IFAudioEncoder.m
//  IFVideoPickerControllerDemo
//
//  Created by Min Kim on 3/27/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import "IFAudioEncoder.h"

@interface IFAudioEncoder () {
}

@end

@implementation IFAudioEncoder

@synthesize assetWriterInput;
@synthesize sampleRate;
@synthesize bitRate;
@synthesize codec;

+ (IFAudioEncoder *)createAACAudioWithBitRate:(CGFloat)bitRate
                                   sampleRate:(CGFloat)sampleRate {
  IFAudioEncoder *encoder = [[[IFAudioEncoder alloc] init] autorelease];
  encoder.bitRate = bitRate;
  encoder.sampleRate = sampleRate;
  encoder.codec = kAudioFormatMPEG4AAC;
  [encoder setupWithFormatDescription:nil];
  return encoder;
}

- (void)setupWithFormatDescription:(CMFormatDescriptionRef)formatDescription {
  /*
  const AudioStreamBasicDescription *asbd =
      CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription);
	size_t aclSize = 0;
	const AudioChannelLayout *channelLayout =
      CMAudioFormatDescriptionGetChannelLayout(formatDescription, &aclSize);
	NSData *channelLayoutData = nil;
	
	// AVChannelLayoutKey must be specified, but if we don't know any better
  // give an empty data and let AVAssetWriter decide.
	if (channelLayout && aclSize > 0)
		channelLayoutData = [NSData dataWithBytes:channelLayout length:aclSize];
	else
   */
  NSData *channelLayoutData = [NSData data];
	
	NSDictionary *audioCompressionSettings =
      [NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithInteger:codec], AVFormatIDKey,
          [NSNumber numberWithFloat:sampleRate], AVSampleRateKey,
          [NSNumber numberWithInt:bitRate], AVEncoderBitRatePerChannelKey,
          [NSNumber numberWithInteger:1], AVNumberOfChannelsKey,
          channelLayoutData, AVChannelLayoutKey,
          nil];
	AVAssetWriterInput *newWriterInput =
      [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio
                                     outputSettings:audioCompressionSettings];
  newWriterInput.expectsMediaDataInRealTime = YES;
  self.assetWriterInput = newWriterInput;
  [newWriterInput release];
}

- (void)dealloc {
  if (assetWriterInput != nil) {
    [assetWriterInput release];
  }
  
  [super dealloc];
}

@end
