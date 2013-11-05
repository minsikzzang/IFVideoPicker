//
//  NALUnit.h
//  protos
//
//  Created by Min Kim on 10/21/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NALUnit : NSObject

- (id)initWithData:(NSData *)data;

/**
 @abstact
   Skip bit position
 */
- (void)skip:(int)bitLength;

/**
 @abstact
   Get next bit from current byte position
 */
- (NSUInteger)getBit;

/**
 @abstact
  Get next byte, removing emulation prevention bytes
 */
- (Byte)getByte;

/**
 @abstract
  Exp-Golomb entropy coding: leading zeros, then a one, then the data bits. The 
  number of leading zeros is the number of data bits, counting up from that 
  number of 1s as the base. That is, if you see 0001010 You have three leading 
  zeros, so there are three data bits (010) counting up from a base of 111: 
  thus 111 + 010 = 1001 = 9
  
 http://en.wikipedia.org/wiki/Exponential-Golomb_coding
 
 */
- (NSUInteger)getUE;

@property (atomic, assign) int nalRefIdc;
@property (atomic, assign) int nalType;

@end
