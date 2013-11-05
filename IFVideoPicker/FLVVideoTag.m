//
//  FLVVideoTag.m
//  protos
//
//  Created by Min Kim on 10/18/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import "FLVVideoTag.h"
#import "FLVTag.h"

@implementation FLVVideoTag

@synthesize packetType;
@synthesize codecId;
@synthesize frameType;
@synthesize body;

- (id)init {
  self = [super init];
  if (self) {
    packetType = kAVCNALU;
    codecId = kFLVCodecIdH264;
    frameType = FLV_FRAME_INTER;
    self.dataType = kFLVTagTypeVideo;
    self.flagsSize = 5;
  }
  return self;
}

@end
