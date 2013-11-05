//
//  FLVHeader.m
//  protos
//
//  Created by Min Kim on 10/10/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import "FLVHeader.h"
#import "NSMutableData+Bytes.h"

// Signature
static const char *kSignature = "FLV";

// FLV Version
static const Byte kVersion = 0x01;

// Reserved flag, one
static const Byte kFlagReserved01 = 0x00;

// Reserved flag, one
static const Byte kFlagReserved02 = 0x00;

static const int kFlvHeaderFlagHasAudio = 4;

static const int kFlvHeaderFlagHasVideo = 1;

/**
 * reserved for data up to 4,294,967,295
 */
static const Byte kDataOffset = 0x00;

@implementation FLVHeader

@synthesize flagAudio;
@synthesize flagVideo;
@synthesize version;

- (id)init {
  self = [super init];
  if (self) {
    version = kVersion;
  }
  return self;
}

- (NSData *)write {
  NSMutableData *buffer = [[NSMutableData alloc] initWithCapacity:13];
  // FLV
  [buffer appendBytes:kSignature length:3];
  // Version
  [buffer putInt8:version];
  // flags
  [buffer putInt8:(Byte)(kFlvHeaderFlagHasAudio * (flagAudio ? 1 : 0) +
                         kFlvHeaderFlagHasVideo * (flagVideo ? 1 : 0))];
  // data offset
  [buffer putInt32:9];
  // previous tag size 0 (this is the "first" tag)
  [buffer putInt32:0];
  return [buffer autorelease];
}

- (NSString *)toString {
  return @"";
}

@end
