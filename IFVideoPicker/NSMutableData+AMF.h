//
//  NSMutableData+AMF.h
//  protos
//
//  Created by Min Kim on 10/11/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  kAMFDataTypeNumber      = 0x00,
  kAMFDataTypeBool        = 0x01,
  kAMFDataTypeString      = 0x02,
  kAMFDataTypeObject      = 0x03,
  kAMFDataTypeNull        = 0x05,
  kAMFDataTypeUndefined   = 0x06,
  kAMFDataTypeReference   = 0x07,
  kAMFDataTypeMixedArray  = 0x08,
  kAMFDataTypeObjectEnd  = 0x09,
  kAMFDataTypeArray       = 0x0a,
  kAMFDataTypeDate        = 0x0b,
  kAMFDataTypeLongString = 0x0c,
  kAMFDataTypeUnsupported = 0x0d,
} AMFDataType;

typedef enum {
  kAMFValueFalse = 0x00,
  kAMFValueTrue = 0x01
} AMFBoolValue;

@interface NSMutableData (AMF)

- (void)writeAMFString:(NSString *)str;
- (void)putAMFString:(NSString *)str;
- (void)putAMFDouble:(double)d;
- (void)putAMFBool:(BOOL)b;
- (void)putParam:(NSString *)key d:(double)d;
- (void)putParam:(NSString *)key str:(NSString *)str;
- (void)putParam:(NSString *)key b:(BOOL)b;



@end
