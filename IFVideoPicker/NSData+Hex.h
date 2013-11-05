//
//  NSData+Hex.h
//  NSData+HexDemo
//
//  Created by Min Kim on 10/3/13.
//  Copyright (c) 2013 iFactory Lab Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Hex)

- (NSString *)hexString;

- (NSString *)hexString:(NSUInteger)size;

@end