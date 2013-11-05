//
//  NSData+Bytes.h
//  protos
//
//  Deprecated.. don't use this..
//
//  Created by Min Kim on 10/11/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Bytes)

- (int8_t)getInt8;
- (int16_t)getInt16;
- (int32_t)getInt32;
- (int64_t)getInt64;
- (NSData *)getBytes:(int)size;
- (NSString *)getString:(int)size;
- (void)skip:(int)pos;
- (int)position;
- (void)resetPosition;

@end
