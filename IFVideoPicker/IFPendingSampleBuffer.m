//
//  IFPendingSampleBuffer.m
//  IFVideoPicker
//
//  Created by Min Kim on 12/10/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import "IFPendingSampleBuffer.h"

@interface IFPendingSampleBuffer () {
  CMSampleBufferRef sampleBuffer_;
  IFCapturedBufferType mediaType_;
}

@end

@implementation IFPendingSampleBuffer

@synthesize mediaType;

+ (IFPendingSampleBuffer *)pendingSampleBuffer:(CMSampleBufferRef)sampleBuffer
                                        ofType:(IFCapturedBufferType)mediaType {
  
  
  return [[[IFPendingSampleBuffer alloc] initWithSampleBuffer:sampleBuffer
                                                     andType:mediaType] autorelease];
}

- (id)initWithSampleBuffer:(CMSampleBufferRef)sampleBuffer
                   andType:(IFCapturedBufferType)aMediaType {
  self = [super init];
  if (self) {
    CFRetain(sampleBuffer);
    sampleBuffer_ = sampleBuffer;
    self.mediaType = aMediaType;
  }
  return self;
}

- (CMSampleBufferRef)getSampleBuffer {
  return sampleBuffer_;
}

- (void)dealloc {
  CFRelease(sampleBuffer_);
  [super dealloc];
}

@end
