//
//  NSData+Bytes.m
//  protos
//
//  Deprecated.. don't use this..
//
//  Created by Min Kim on 10/11/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import "NSData+Bytes.h"

@interface NSData () {
}

@end

@implementation NSData (Bytes)

int position_ = 0;

- (int64_t)getInt64 {
  int64_t i = 0;
  NSRange range;
  range.length = 8;
  range.location = position_;
  [self getBytes:(void *)&i range:range];
  position_ += range.length;
  return i;
}

- (int32_t)getInt32 {
  int32_t i = 0;
  NSRange range;
  range.length = 4;
  range.location = position_;
  [self getBytes:(void *)&i range:range];
  position_ += range.length;
  return CFSwapInt32HostToBig(i);
}

- (int16_t)getInt16 {
  int16_t i = 0;
  NSRange range;
  range.length = 2;
  range.location = position_;
  [self getBytes:(void *)&i range:range];
  position_ += range.length;
  return CFSwapInt16HostToBig(i);
}

- (int8_t)getInt8 {
  int8_t i = 0;
  NSRange range;
  range.length = 1;
  range.location = position_;
  [self getBytes:(void *)&i range:range];
  position_ += range.length;
  return i;
}

- (NSString *)getString:(int)size {
  NSRange range;
  range.length = size;
  range.location = position_;
  char *buf = malloc(size + 1);
  [self getBytes:buf range:range];
  position_ += size;
  buf[size] = 0;
  NSString *str = [NSString stringWithUTF8String:buf];
  free(buf);
  return str;
}

- (NSData *)getBytes:(int)size {
  NSRange range;
  range.length = size;
  range.location = position_;
  char *buf = malloc(size);
  [self getBytes:buf range:range];
  position_ += size;
  NSData *data = [NSData dataWithBytes:buf length:size];
  free(buf);
  return data;
}

- (void)skip:(int)p {
  position_ += p;
}

- (void)resetPosition {
  position_ = 0;
}

- (int)position {
  return position_;
}

@end
