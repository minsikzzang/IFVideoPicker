//
//  MP4Descriptor.m
//  ffmpeg-wrapper
//
//  Created by Min Kim on 10/18/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import "MP4Descriptor.h"
#import "IFBytesData.h"
#import "NSData+Hex.h"

const int kMP4ESDescriptorTag = 3;
const int kMP4DecoderConfigDescriptorTag = 4;
const int kMP4DecSpecificInfoDescriptorTag = 5;

@interface MP4Descriptor () {
  
}

/**
 @abstract
  Loads the MP4ES_Descriptor from the input data.
 
 @param bytes data the input stream
 */
- (void)createESDescriptor:(IFBytesData *)data;

/**
 @abstract
  Loads the MP4DecoderConfigDescriptor from the input data.
 
 @param bytes data the input stream
 */
- (void)createDecoderConfigDescriptor:(IFBytesData *)data;

/**
 @abstract
  Loads the MP4DecSpecificInfoDescriptor from the input data.
 
 @param bytes data the input stream
 */
- (void)createDecSpecificInfoDescriptor:(IFBytesData *)data;

@end

@implementation MP4Descriptor

@synthesize size;
@synthesize type;
@synthesize read;
@synthesize children;
@synthesize decSpecificDataOffset;
@synthesize decSpecificDataSize;
@synthesize dsID;

+ (MP4Descriptor *)createDescriptor:(IFBytesData *)data {
  int tag = [data getInt8];
  int read = 1;
  int size = 0;
  int b = 0;
  do {
    b = [data getInt8];
    size <<= 7;
    size |= b & 0x7f;
    read++;
  } while ((b & 0x80) == 0x80);
  
  MP4Descriptor *descriptor = [[MP4Descriptor alloc] init];
  descriptor.type = tag;
  descriptor.size = size;
  switch (tag) {
    case kMP4ESDescriptorTag:
      [descriptor createESDescriptor:data];
      break;
    case kMP4DecoderConfigDescriptorTag:
      [descriptor createDecoderConfigDescriptor:data];
      break;
    case kMP4DecSpecificInfoDescriptorTag:
      [descriptor createDecSpecificInfoDescriptor:data];
      break;
    default:
      break;
  }
  [data skip:(descriptor.size - descriptor.read)];
  descriptor.read = read + descriptor.size;
  return [descriptor autorelease];
}

- (id)init {
  self = [super init];
  if (self) {
    children = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc {
  [children release];
  if (dsID) {
    [dsID release];
  }
  [super dealloc];
}

- (void)createESDescriptor:(IFBytesData *)data {
  int esID = [data getInt16];
  int flags = [data getInt8];
  BOOL streamDependenceFlag = (flags & (1 << 7)) != 0;
  BOOL urlFlag = (flags & (1 << 6)) != 0;
  BOOL ocrFlag = (flags & (1 << 5)) != 0;
  read += 3;
  if (streamDependenceFlag) {
    [data skip:2];
    read += 2;
  }
  if (urlFlag) {
    int strSize = [data getInt8];
    [data getString:strSize];
    read += strSize + 1;
  }
  if (ocrFlag) {
    [data skip:2];
    read += 2;
  }
  while (read < size) {
    MP4Descriptor *descriptor = [MP4Descriptor createDescriptor:data];
    if (!descriptor) {
      NSLog(@"Failed to create MP4Descriptor");
      break;
    }
    [children addObject:descriptor];
    read += descriptor.read;
  }
}

- (void)createDecoderConfigDescriptor:(IFBytesData *)data {
  int objectTypeIndication = [data getInt8];
  int value = [data getInt8];
  BOOL upstream = (value & (1 << 1)) > 0;
  Byte streamType = (Byte) (value >> 2);
  value = [data getInt16];
  int bufferSizeDB = value << 8;
  value = [data getInt8];
  bufferSizeDB |= value & 0xff;
  int maxBitRate = [data getInt32];
  int minBitRate = [data getInt32];
  read += 13;
  if (read < size) {
    MP4Descriptor *descriptor = [MP4Descriptor createDescriptor:data];
    if (!descriptor) {
      NSLog(@"Failed to create MP4Descriptor");
    } else {
      [children addObject:descriptor];
      read += descriptor.read;
    }    
  }
}

- (void)createDecSpecificInfoDescriptor:(IFBytesData *)data {
  decSpecificDataOffset = data.position;
  NSMutableData *ds = [[NSMutableData alloc] init];
  Byte p = 0;
  for (int b = 0; b < size; b++) {
    p = [data getInt8];
    [ds appendBytes:&p length:1];
    read++;
  }
  decSpecificDataSize = size - read;
  self.dsID = ds;
  [ds release];
}

@end
