//
//  NSMutableData+AMF.m
//  protos
//
//  Created by Min Kim on 10/11/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import "NSMutableData+AMF.h"
#import "NSMutableData+Bytes.h"

@implementation NSMutableData (AMF)

- (void)writeAMFString:(NSString *)str {
  short length = [str length];
  [self putInt16:length];
  [self appendBytes:[str cStringUsingEncoding:NSUTF8StringEncoding]
             length:length];
}

- (void)putAMFString:(NSString *)str {
  [self putInt8:kAMFDataTypeString];
  [self writeAMFString:str];
}

- (void)putAMFDouble:(double)d {
  [self putInt8:kAMFDataTypeNumber];
  char output[8] = {0, };
  unsigned char *ci, *co;
  ci = (unsigned char *)&d;
  co = (unsigned char *)output;
  co[0] = ci[7];
  co[1] = ci[6];
  co[2] = ci[5];
  co[3] = ci[4];
  co[4] = ci[3];
  co[5] = ci[2];
  co[6] = ci[1];
  co[7] = ci[0];
  /*
#if __FLOAT_WORD_ORDER == __BYTE_ORDER
#if __BYTE_ORDER == __BIG_ENDIAN
  memcpy(output, &d, 8);
#elif __BYTE_ORDER == __LITTLE_ENDIAN
  {
    unsigned char *ci, *co;
    ci = (unsigned char *)&d;
    co = (unsigned char *)output;
    co[0] = ci[7];
    co[1] = ci[6];
    co[2] = ci[5];
    co[3] = ci[4];
    co[4] = ci[3];
    co[5] = ci[2];
    co[6] = ci[1];
    co[7] = ci[0];
  }
#endif
#else
#if __BYTE_ORDER == __LITTLE_ENDIAN
  {
    unsigned char *ci, *co;
    ci = (unsigned char *)&d;
    co = (unsigned char *)output;
    co[0] = ci[3];
    co[1] = ci[2];
    co[2] = ci[1];
    co[3] = ci[0];
    co[4] = ci[7];
    co[5] = ci[6];
    co[6] = ci[5];
    co[7] = ci[4];
  }
#else
  {
    unsigned char *ci, *co;
    ci = (unsigned char *)&d;
    co = (unsigned char *)output;
    co[0] = ci[4];
    co[1] = ci[5];
    co[2] = ci[6];
    co[3] = ci[7];
    co[4] = ci[0];
    co[5] = ci[1];
    co[6] = ci[2];
    co[7] = ci[3];
  }
#endif
#endif
   */
  [self appendBytes:output length:8];
}

- (void)putAMFBool:(BOOL)b {
  [self putInt8:kAMFDataTypeBool];
  [self putInt8:b ? kAMFValueTrue : kAMFValueFalse];
}

- (void)putParam:(NSString *)key d:(double)d {
  [self writeAMFString:key];
  [self putAMFDouble:d];
}

- (void)putParam:(NSString *)key str:(NSString *)str {
  [self writeAMFString:key];
  [self putAMFString:str];
}

- (void)putParam:(NSString *)key b:(BOOL)b {
  [self writeAMFString:key];
  [self putAMFBool:b];
}

@end
