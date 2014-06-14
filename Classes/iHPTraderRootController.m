//
//  iHPTraderRootController.m
//  iHPTrader
//
//  Created by hugo on 13年5月28日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "iHPTraderRootController.h"


@implementation iHPTraderRootController

@synthesize dataLoader = _dataLoader;
@synthesize loadQueue = _loadQueue;
@synthesize scanQueue = _scanQueue;
@synthesize indicator = _indicator;
@synthesize indicators = _indicators;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	///////////////////////////////
	NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSLog(@"doc path = %@",documentsDirectoryPath);
	
    HPTYahooFinanceMarketDataLoader *loader = [[HPTYahooFinanceMarketDataLoader alloc] init];
	loader.onlyLoadExisting = YES;
	self.dataLoader = loader;
	NSDate *nowDate = [NSDate date];
	NSDate *newDate = [loader addDays:1 fromDate:nowDate];
	NSLog(@" now = %@, new=%@" ,nowDate, newDate);
	NSLog(@"days between = %i",[loader daysBetweenDate:nowDate andDate:newDate]);
	HPTYahooWatchList *watchList = [[HPTYahooWatchList alloc] init];
	[self.dataLoader setWatchList:watchList];
	HPTYahooHKExEquityDictionary *dir = [[HPTYahooHKExEquityDictionary alloc] init];
	[self.dataLoader setDictionary:dir];
	HPTAsciiMarketDataStore *fileStore2 = [[HPTAsciiMarketDataStore alloc] init];
	fileStore2.asciiDirectory = documentsDirectoryPath;
	[self.dataLoader setStore:fileStore2];
	
	
	HPTPriceFilterIndicator *sig1 = [[HPTPriceFilterIndicator alloc] initWithStore:fileStore2];
	NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithCapacity:2];
	[param setObject:[NSNumber numberWithDouble:0.1f] forKey:@"LOW"];
	[param setObject:[NSNumber numberWithInt:1000] forKey:@"HIGH"];
	[sig1 setParam:param];
	[param release];
    
    HPTThreeLineFlowerBuySig *sig2 = [[HPTThreeLineFlowerBuySig alloc] initWithStore:fileStore2];
    
	HPTVolumeSig *sig3 = [[HPTVolumeSig alloc] initWithStore:fileStore2];
	HPTAdvSig *sig4 = [[HPTAdvSig alloc] initWithStore:fileStore2];
    HPTOneOfTenthSig *sig5 = [[HPTOneOfTenthSig alloc] initWithStore:fileStore2];
	
	
	HPTIndicatorChainOperation *inds = [[HPTIndicatorChainOperation alloc] init];
	inds.dictionary = dir;
	//[inds addIndicator:sig1];
    //[inds addIndicator:sig2];
	//[inds addIndicator:sig3];
	//[inds addIndicator:sig4];
    [inds addIndicator:sig5];
	self.indicators = inds;
	
	
	[loader release];
	[fileStore2 release];
	[watchList release];
	[dir release];
	[sig1 release];
	[sig2 release];
    //[sig3 release];
    //[sig4 release];
	[inds release];

}

- (IBAction)loadPressed: (id)sender{
	if (!self.loadQueue) {
		NSOperationQueue *aQueue = [[NSOperationQueue alloc] init];
		self.loadQueue = aQueue;
		[aQueue release];
		[self.loadQueue addOperation:self.dataLoader];
	}
}

- (IBAction)buttonPressed: (id)sender{
	if (!self.scanQueue) {
		NSOperationQueue *aQueue = [[NSOperationQueue alloc] init];
		self.scanQueue = aQueue;
		[aQueue release];
		//[self.queue addOperation:self.indicator];
		[self.scanQueue addOperation:self.indicators];
	}
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.dataLoader = nil;
	self.loadQueue = nil;
    self.scanQueue = nil;
	self.indicator = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
