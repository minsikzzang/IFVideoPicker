//
//  NSMutableData+Bytes.m
//  protos
//
//  Created by Min Kim on 10/10/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import "NSMutableData+Bytes.h"

@implementation NSMutableData (Bytes)

- (void)putInt8:(Byte)b {
  NSData *data = [NSData dataWithBytes:&b length:1];
  [self appendData:data];
//  [self appendBytes:(const void *)&b length:1];
}

- (void)putInt16:(short)s {
  short fliped = CFSwapInt16HostToBig(s);
  // [self appendBytes:(const void *)&fliped length:2];
  NSData *data = [NSData dataWithBytes:&fliped length:2];
  [self appendData:data];
}

- (void)putInt24:(int)i {
  [self putInt8:i >> 16];
  [self putInt16:i & 0xffff];  
}

- (void)putInt32:(int)i {
  int fliped = CFSwapInt32HostToBig(i);
  [self appendBytes:(const void *)&fliped length:4];
}

- (void)putInt64:(int64_t)i {
  [self putInt32:i & 0xffffffff];
  [self putInt32:i >> 32];
}

@end
