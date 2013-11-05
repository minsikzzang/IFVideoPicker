//
//  MP4Descriptor.h
//  ffmpeg-wrapper
//
//  Created by Min Kim on 10/18/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const int kMP4ESDescriptorTag;
extern const int kMP4DecoderConfigDescriptorTag;
extern const int kMP4DecSpecificInfoDescriptorTag;

@class IFBytesData;

@interface MP4Descriptor : NSObject

@property (atomic, assign) int size;
@property (atomic, assign) int type;
@property (atomic, assign) int read;
@property (atomic, retain) NSMutableArray *children;
@property (atomic, assign) int decSpecificDataSize;
@property (atomic, assign) long decSpecificDataOffset;
@property (atomic, retain) NSData *dsID;

+ (MP4Descriptor *)createDescriptor:(IFBytesData *)data;

@end
