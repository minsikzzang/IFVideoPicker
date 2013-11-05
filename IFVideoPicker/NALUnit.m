//
//  NALUnit.m
//  protos
//
//  Created by Min Kim on 10/21/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//
// http://tools.ietf.org/html/rfc3984
//

#import "NALUnit.h"

@interface NALUnit () {
  int curerntByte_;
  int bitPosition_;
  int position_;
  int zeros_;
}

@property (atomic, retain) NSData *nalUnit;

@end

@implementation NALUnit

@synthesize nalRefIdc;
@synthesize nalType;
@synthesize nalUnit;

- (id)initWithData:(NSData *)data {
  self = [super init];
  if (self) {
    Byte *p = (Byte *)[data bytes];
    self.nalUnit = data;
    
    nalRefIdc = p[0] & 0x60;
    nalType = p[0] & 0x1f;
    position_ = 0;
    zeros_ = 0;
  }
  return self;
}

- (NSUInteger)getBit {
  if (bitPosition_ == 0) {
    curerntByte_ = [self getByte];
    bitPosition_ = 8;
  }
  bitPosition_--;
  return (curerntByte_ >> bitPosition_) & 0x1;
}

- (Byte)getByte {
  if ([nalUnit length] <= position_) {
    return 0;
  }
  
  Byte b = *((Byte *)[nalUnit bytes] + position_++);
  
  // To avoid start-code emulation, a byte 0x03 is inserted
  // after any 00 00 pair. Discard that here.
  if (b == 0) {
    zeros_++;
    if ((position_ < [nalUnit length]) &&
        (zeros_ == 2) && (*((Byte *)[nalUnit bytes] + position_) == 0x03)) {
      position_++;
      zeros_ = 0;
    }
  } else {
    zeros_ = 0;
  }

  return b;
}

- (NSUInteger)getWord:(int)bitLength {
  NSUInteger u = 0;
  while (bitLength > 0) {
    u <<= 1;
    u |= [self getBit];
    bitLength--;
  }
  return u;
}

- (NSUInteger)getUE {
  int numZeros = 0;
  while ([self getBit] == 0) {
    numZeros++;
  }
  return [self getWord:numZeros] + ((1 << numZeros) - 1);
}

- (void)skip:(int)bitLength {
  if (bitLength < bitPosition_) {
    bitPosition_ -= bitLength;
  } else {
    bitLength -= bitPosition_;
    while (bitLength >= 8) {
      [self getByte];
      bitLength -= 8;
    }
    
    if (bitLength > 0) {
      curerntByte_ = [self getByte];
      bitPosition_ = 8;
      bitPosition_ -= bitLength;
    }
  }
}

@end
