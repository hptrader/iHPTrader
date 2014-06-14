//
//  HPTDictionary.m
//  iHPTrader
//
//  Created by hugo on 13年6月4日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "HPTDictionary.h"


@implementation HPTDictionary

- (void)setStore:(id)aStore{
	//empty method
	//subclass need to override the method
}

- (HPTSymbolType)getSymbolType{
	//empty method
	//subclass need to override the method
	return 0;
}

- (void)initSymbols{
	//empty method
	//subclass need to override the method
}

- (NSArray *)getSymbols{
	//empty method
	//subclass need to override the method
	return nil;
}

- (void)removeSymbol:(id<HPTSymbolProtocol>)aSymbol{
	//empty method
	//subclass need to override the method
}


@end
