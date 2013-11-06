//
//  IFBytesData.m
//  ffmpeg-wrapper
//
//  Created by Min Kim on 10/18/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import "IFBytesData.h"

@interface IFBytesData () {

}

@property (atomic, retain) NSData *buffer;

@end

@implementation IFBytesData

@synthesize position;
@synthesize buffer;

+ (IFBytesData *)dataWithNSData:(NSData *)data {
  IFBytesData *bytes = [[IFBytesData alloc] initWithNSData:data];
  return [bytes autorelease];
}

- (id)initWithNSData:(NSData *)data {
  self = [super init];
  if (self) {
    self.buffer = data;
    position = 0;
  }
  return self;
}

- (void)dealloc {
  [buffer release];
  [super dealloc];
}

- (const void *)bytes {
  return [buffer bytes];
}

- (NSUInteger)length {
  return [buffer length];
}

- (void)getBytes:(void *)bytes range:(NSRange)range {
  [buffer getBytes:bytes range:range];
}

- (int64_t)getInt64 {
  int64_t i = 0;
  NSRange range;
  range.length = 8;
  range.location = position;
  [self getBytes:(void *)&i range:range];
  position += range.length;
  return i;
}

- (int32_t)getInt32 {
  int32_t i = 0;
  NSRange range;
  range.length = 4;
  range.location = position;
  [self getBytes:(void *)&i range:range];
  position += range.length;
  return CFSwapInt32HostToBig(i);
}

- (int16_t)getInt16 {
  int16_t i = 0;
  NSRange range;
  range.length = 2;
  range.location = position;
  [self getBytes:(void *)&i range:range];
  position += range.length;
  return CFSwapInt16HostToBig(i);
}

- (int8_t)getInt8 {
  int8_t i = 0;
  NSRange range;
  range.length = 1;
  range.location = position;
  [self getBytes:(void *)&i range:range];
  position += range.length;
  return i;
}

- (NSString *)getString:(NSUInteger)size {
  NSRange range;
  range.length = size;
  range.location = position;
  char *buf = malloc(size + 1);
  [self getBytes:buf range:range];
  position += size;
  buf[size] = 0;
  NSString *str = [NSString stringWithUTF8String:buf];
  free(buf);
  return str;
}

- (NSData *)getBytes:(NSUInteger)size {
  NSRange range;
  range.length = size;
  range.location = position;
  char *buf = malloc(size);
  [self getBytes:buf range:range];
  position += size;
  NSData *data = [NSData dataWithBytes:buf length:size];
  free(buf);
  return data;
}

- (void)skip:(int)p {
  position += p;
}

- (void)reset {
  position = 0;
}

@end
