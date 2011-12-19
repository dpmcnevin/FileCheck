//
//  FCAppDelegate.m
//  FileCheck
//
//  Created by James Kang on 12/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FCAppDelegate.h"
#import "SCEvents.h"
#import "SCEvent.h"

@interface FCAppDelegate (Protected)

- (void)setUpFileWatching;
- (void)updateStatusMenu;

@end

@implementation FCAppDelegate (Protected)

- (void)setUpFileWatching
{
    self.fileEventsController = 
    [[[FileEventsController alloc] init] autorelease];    
    
    // Specify the one path that we'll watch.
    NSString *dmgPathToWatch = @"/Volumes/GobblerKeys";
    self.fileEventsController.filePathsToWatch = 
    [NSArray arrayWithObject:dmgPathToWatch];
	
    NSString *devFilePathToCheckWhenDMGIsThere = 
    @"/Volumes/GobblerKeys/ec2/users/mam/keys/key-lab.pem";
	
	NSString *prodFilePathToCheckWhenDMGIsThere = 
    @"/Volumes/GobblerKeys/ec2/users/mam/keys/key-prod.pem";
    
    // This block runs when the folder contains the file we watch is changed.
    FileExistenceBlock fileExistenceBlock = 
    ^(NSString *dmgFilePath, BOOL exists)
    {
		self.fileLastReportedToExist = NO;
		self.developmentImage = NO;
		self.productionImage = NO;
		
        if (exists)
        {
            NSFileManager *fileManager = [[NSFileManager alloc] init];
			if ([fileManager fileExistsAtPath:devFilePathToCheckWhenDMGIsThere]) {
				self.fileLastReportedToExist = true;
				self.developmentImage = true;
			} else if ([fileManager fileExistsAtPath:prodFilePathToCheckWhenDMGIsThere]) {
				self.fileLastReportedToExist = true;
				self.productionImage = true;
			}
            [fileManager release];
        }
        [self updateStatusMenu];
    };
    
    self.fileEventsController.fileExistenceCallbackBlock = 
    [[fileExistenceBlock copy] autorelease];
    
    // Set up initial status.
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    fileExistenceBlock(dmgPathToWatch, 
                       [fileManager fileExistsAtPath:dmgPathToWatch]);
    [fileManager release];                       
    
    [self.fileEventsController setupEventListener];   
}

// This method might not be worth having around if this is really all you have 
// to do.
- (void)updateStatusMenu
{
    if (self.developmentImage)
    {
        self.statusItem.image = [NSImage imageNamed:@"development_mounted.png"];
    }
	else if (self.productionImage) {
		self.statusItem.image = [NSImage imageNamed:@"production_mounted.png"];
	}
    else
    {
        self.statusItem.image = [NSImage imageNamed:@"none_mounted.png"];        
    }
}

@end


@implementation FCAppDelegate

@synthesize window = _window;
@synthesize statusMenu;
@synthesize statusItem;
@synthesize fileEventsController;
//@synthesize statusMessage;
@synthesize fileLastReportedToExist;
@synthesize productionImage;
@synthesize developmentImage;


- (void)dealloc
{
//    [statusMessage release];
    [fileEventsController release];
    [statusItem release];
    [statusMenu release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application    
    [self setUpFileWatching];
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.fileLastReportedToExist = NO;
    
    self.statusItem = 
    [[NSStatusBar systemStatusBar] 
     statusItemWithLength:NSVariableStatusItemLength]; 
    self.statusItem.menu = self.statusMenu;
    self.statusItem.highlightMode = YES;
    [self updateStatusMenu];
//    [statusItem release];
}

@end
