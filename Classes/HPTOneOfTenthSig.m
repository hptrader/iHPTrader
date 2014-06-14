//
//  HPTOneOfTenthSig.m
//  iHPTrader
//
//  Created by Hugo on 13/6/14.
//
//

#import "HPTOneOfTenthSig.h"

@implementation HPTOneOfTenthSig

- (void)deriveData{
    _isBuy = NO;
	_isSell = NO;
	_rank = HPT_NO_RANK;
	
	if (_core && _symbol && _store) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		NSMutableArray *open = [[[NSMutableArray alloc] initWithCapacity:100] autorelease];
		NSMutableArray *close = [[[NSMutableArray alloc] initWithCapacity:100] autorelease];
		NSMutableArray *high = [[[NSMutableArray alloc] initWithCapacity:100] autorelease];
		NSMutableArray *low = [[[NSMutableArray alloc] initWithCapacity:100] autorelease];
		NSMutableArray *vol = [[[NSMutableArray alloc] initWithCapacity:100] autorelease];
		
		int size = [self loadSymbolBarsWithClose:close withOpen:open withHigh:high withLow:low withVolume:vol];
        if (size > 305) {
            double maxClose=0.0f;
            for (int i=0; i<301; i++) {
                double lastClose = [[close objectAtIndex:size-1-i] doubleValue];
                maxClose = maxClose > lastClose? maxClose: lastClose;
            }
            //NSLog(@"maxClose = %f", maxClose);
            for (int i =0; i<11; i++) {
                double lastClose = [[close objectAtIndex:size-1-i] doubleValue];
                //NSLog(@"lastClose = %f", lastClose);
                
                if (_rank < HPT_HIGHLY_RANK) {
                    if (lastClose <= maxClose*0.21f) {
                        _isBuy = YES;
                        _rank = HPT_RECOMMAND_RANK;
                    }
                    if (lastClose <= maxClose*0.11f) {
                        _isBuy = YES;
                        _rank = HPT_HIGHLY_RANK;
                    }
                }
            }
        }
        
        [pool drain];
    }
}

@end
