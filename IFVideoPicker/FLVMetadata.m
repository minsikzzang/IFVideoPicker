//
//  FLVMetadata.m
//  protos
//
//  Created by Min Kim on 10/11/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import "FLVMetadata.h"

@implementation FLVMetadata

@synthesize duration;
@synthesize width;
@synthesize height;
@synthesize videoBitrate;
@synthesize framerate;
@synthesize videoCodecId;
@synthesize audioBitrate;
@synthesize sampleRate;
@synthesize sampleSize;
@synthesize stereo;
@synthesize audioCodecId;

- (id)init {
  self = [super init];
  if (self) {
    audioCodecId = -1;
    videoCodecId = -1;
  }
  return self;
}

@end
