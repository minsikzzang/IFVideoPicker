//
//  NSMutableData+Bytes.h
//  protos
//
//  Created by Min Kim on 10/10/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableData (Bytes)

- (void)putInt8:(Byte)b;
- (void)putInt16:(short)s;
- (void)putInt24:(int)i;
- (void)putInt32:(int)i;
- (void)putInt64:(int64_t)i;

@end
