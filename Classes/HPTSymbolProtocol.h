//
//  HPTSymbolProtocol.h
//  iHPTrader
//
//  Created by hugo on 13年6月9日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum  {
	HPT_GOOGLE_CODE,
    HPT_YAHOO_CODE
}HPTSymbolType;

@protocol HPTSymbolProtocol <NSObject, NSCopying>

- (id)initWithString:(NSString *)symbol withAreaCode:(NSString *)areaCode;
- (NSString *)getSymbol;
- (NSString *)getAreaCode;
- (HPTSymbolType)getType;
- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;
- (id)copyWithZone:(NSZone *)zone;


@end
