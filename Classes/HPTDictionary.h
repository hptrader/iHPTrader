//
//  HPTDictionary.h
//  iHPTrader
//
//  Created by hugo on 13年6月4日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPTSymbolProtocol.h"


@interface HPTDictionary : NSObject {

}

- (void)setStore:(id)aStore;
- (HPTSymbolType)getSymbolType;
- (void)initSymbols;
- (NSArray *)getSymbols;
- (void)removeSymbol:(id<HPTSymbolProtocol>)aSymbol;

@end
