#import "AppController.h"
#import "DonationReminder/DonationReminder.h"

#define useLog 0

static BOOL LAUNCH_AS_LOGINITEM = NO;
static BOOL STAY_RUNNING = YES;
static BOOL CHECK_UPDATE = NO;

@implementation AppController

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
#if useLog
	NSLog(@"start applicationShouldTerminate");
#endif
    if (_forceQuit) {return NSTerminateNow;}
    
    if (!LAUNCH_AS_LOGINITEM) {
        NSUserDefaults *user_defaults = [NSUserDefaults standardUserDefaults];
        [user_defaults synchronize];
        STAY_RUNNING = [user_defaults boolForKey:@"StayRunning"];
        if (!STAY_RUNNING) {
            return NSTerminateNow;
        }
    }
    return NSTerminateCancel;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
#if useLog
	NSLog(@"start applicationShouldTerminateAfterLastWindowClosed");
#endif
	return (STAY_RUNNING);
}

- (void)checkUpdate
{
	if (STAY_RUNNING) {
        [updater checkForUpdatesInBackground];
	} else {
		[updater checkForUpdates:self];
	}
	CHECK_UPDATE = NO;
}

- (void)tryTerminate
{
#if useLog
	NSLog(@"window count : %ld", [[NSApp windows] count]);
#endif
	if (![[NSApp windows] count]) {
		[NSApp terminate:self];
	}
}

- (void)processForLaunched
{
	[controlScript processForContext];
	if (CHECK_UPDATE) {
		[self checkUpdate];
	}
    [self performSelectorOnMainThread:@selector(tryTerminate) withObject:nil waitUntilDone:NO];
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
#if uselOg
	NSLog(@"applicationWillFinishLaunching");
#endif
	
	[DonationReminder remindDonation];
	
	NSUserDefaults *user_defaults = [NSUserDefaults standardUserDefaults];
	int interval_count = [user_defaults integerForKey:@"UpdateIntervalLaunchCounts"];
	int current_count = [user_defaults integerForKey:@"CurrentLaunchCount"];
	if (current_count >= interval_count) {
		CHECK_UPDATE = YES;
		[user_defaults setInteger:0 forKey:@"CurrentLaunchCount"];
	} else {
		[user_defaults setInteger:++current_count forKey:@"CurrentLaunchCount"];
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
#if useLog
	NSLog(@"applicationDidFinishLaunching");
#endif
	
	NSAppleEventDescriptor *ev = [ [NSAppleEventManager sharedAppleEventManager] currentAppleEvent];
#if useLog
	NSLog(@"%@", [ev description]);
#endif
	AEEventID evid = [ev eventID];
	BOOL should_process = NO;
	NSAppleEventDescriptor *propData;
	switch (evid) {
		case kAEOpenDocuments:
#if useLog			
			NSLog(@"kAEOpenDocuments");
#endif
			break;
		case kAEOpenApplication:
#if useLog			
			NSLog(@"kAEOpenApplication");
#endif
			propData = [ev paramDescriptorForKeyword: keyAEPropData];
			DescType type = propData ? [propData descriptorType] : typeNull;
			OSType value = 0;
			if(type == typeType) {
				value = [propData typeCodeValue];
				switch (value) {
					case keyAELaunchedAsLogInItem:
                        LAUNCH_AS_LOGINITEM = YES;
						break;
					case keyAELaunchedAsServiceItem:
						break;
				}
			} else {
				should_process = YES;
			}
			break;
	}
}



- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
	[controlScript serviceForPathes:filenames];
    [self performSelectorOnMainThread:@selector(tryTerminate) withObject:nil waitUntilDone:NO];
}

- (void)processAtLocationFromPasteboard:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error
{
#if useLog
	NSLog(@"start processAtLocationFromPasteboard");
#endif	

	NSArray *types = [pboard types];
	NSArray *filenames;
	if (![types containsObject:NSFilenamesPboardType] 
		|| !(filenames = [pboard propertyListForType:NSFilenamesPboardType])) {
        *error = NSLocalizedString(@"Error: Pasteboard doesn't contain file paths.",
								   @"Pasteboard couldn't give string.");
        return;
    }
	
	[self application:NSApp openFiles:filenames];
	if (CHECK_UPDATE) {
		[self checkUpdate];
	}
}

- (void)processForFrontContextFromPasteboard:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error
{
#if useLog
	NSLog(@"start processAtLocationFromPasteboard");
#endif
    
	[self processForLaunched];
	if (CHECK_UPDATE) {
		[self checkUpdate];
	}
}

- (BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication
{
#if useLog
	NSLog(@"applicationOpenUntitledFile");
#endif	
	[self processForLaunched];
	return YES;
}

- (void)awakeFromNib
{
#if useLog
	NSLog(@"awakeFromNib");
#endif	
	/* Setup User Defaults */
	NSString *defaults_plist = [[NSBundle mainBundle] pathForResource:@"FactorySettings"
															   ofType:@"plist"];
	NSDictionary *factory_defaults = [NSDictionary dictionaryWithContentsOfFile:defaults_plist];
	
	NSUserDefaults *user_defaults = [NSUserDefaults standardUserDefaults];
	[user_defaults registerDefaults:factory_defaults];
	
	/* Setup Services Menu */
	[NSApp setServicesProvider:self];
}

@end
