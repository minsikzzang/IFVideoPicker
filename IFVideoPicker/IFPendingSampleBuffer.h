//
//  IFPendingSampleBuffer.h
//  IFVideoPicker
//
//  Created by Min Kim on 12/10/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFAVAssetEncoder.h"

@interface IFPendingSampleBuffer : NSObject

+ (IFPendingSampleBuffer *)pendingSampleBuffer:(CMSampleBufferRef)sampleBuffer
                                        ofType:(IFCapturedBufferType)mediaType;

- (CMSampleBufferRef)getSampleBuffer;

@property (atomic, assign) IFCapturedBufferType mediaType;

@end
