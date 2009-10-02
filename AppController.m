#import "AppController.h"
#import <OSAKit/OSAScript.h>
#import "DonationReminder/DonationReminder.h"

@class ASKScriptCache;
@class ASKScript;

static BOOL AUTO_QUIT = YES;
static OSAScript *MAIN_SCRIPT = nil;

//static BOOL IS_LAUNCHED = NO;
@implementation AppController

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return AUTO_QUIT;
}

- (void)processForLaunched
{
    NSDictionary *errorInfo = nil;
    //ASKScript *a_script = [[ASKScriptCache sharedScriptCache] scriptWithName:@"Application"];
    [MAIN_SCRIPT executeHandlerWithName:@"process_for_context"
				arguments:nil error:&errorInfo];
	if (!errorInfo) {
		NSLog([errorInfo description]);
	}
	if (AUTO_QUIT && ![[NSApp windows] count]) {
		[NSApp terminate:self];
	}
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
	NSLog(@"applicationWillFinishLaunching");
	[DonationReminder remindDonation];
	
	NSUserDefaults *user_defaults = [NSUserDefaults standardUserDefaults];
	int interval_count = [user_defaults integerForKey:@"UpdateIntervalLaunchCounts"];
	int current_count = [user_defaults integerForKey:@"CurrentLaunchCount"];
	if (current_count >= interval_count) {
		[updater checkForUpdates:self];
	} else {
		[user_defaults setInteger:current_count++ forKey:@"CurrentLaunchCount"];
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSLog(@"applicationDidFinishLaunching");

	NSAppleEventDescriptor *ev = [ [NSAppleEventManager sharedAppleEventManager] currentAppleEvent];
	NSLog([ev description]);
	AEEventID evid = [ev eventID];
	BOOL should_process = NO;
	switch (evid) {
		case kAEOpenDocuments:
			NSLog(@"kAEOpenDocuments");
			break;
		case kAEOpenApplication:
			NSLog(@"kAEOpenApplication");
			NSAppleEventDescriptor* propData = [ev paramDescriptorForKeyword: keyAEPropData];
			DescType type = propData ? [propData descriptorType] : typeNull;
			OSType value = 0;
			if(type == typeType) {
				value = [propData typeCodeValue];
				switch (value) {
					case keyAELaunchedAsLogInItem:
						AUTO_QUIT = NO;
						break;
					case keyAELaunchedAsServiceItem:
						break;
				}
			} else {
				should_process = YES;
			}
			break;
	}
	
	/*
	IS_LAUNCHED = YES;
	if (should_process)
		[self processForLaunched];
	 */
	if (should_process && [[NSApp windows] count]) {
		/* when donation reminder is opened, applicationOpenUntitled is not called. */
		[self processForLaunched];
	}
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
	NSDictionary *errorInfo = nil;
    //ASKScript *a_script = [[ASKScriptCache sharedScriptCache] scriptWithName:@"Application"];
    [MAIN_SCRIPT executeHandlerWithName:@"service_for_pathes"
								arguments:[NSArray arrayWithObject:filenames]
							   error:&errorInfo];
	if (!errorInfo) {
		NSLog([errorInfo description]);
	}
	if (AUTO_QUIT && ![[NSApp windows] count]) {
		[NSApp terminate:self];
	}	
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
}

- (BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication
{
	NSLog(@"applicationOpenUntitledFile");
	//if (IS_LAUNCHED) [self processForLaunched];
	[self processForLaunched];
	return YES;
}

- (void)awakeFromNib
{
	/* Setup User Defaults */
	NSString *defaults_plist = [[NSBundle mainBundle] pathForResource:@"FactorySettings" ofType:@"plist"];
	NSDictionary *factory_defaults = [NSDictionary dictionaryWithContentsOfFile:defaults_plist];
	
	NSUserDefaults *user_defaults = [NSUserDefaults standardUserDefaults];
	[user_defaults registerDefaults:factory_defaults];
	
	/* Setup Services Menu */
	[NSApp setServicesProvider:self];
	
	/* Setup worker script */
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Application"
													 ofType:@"scpt" inDirectory:@"Scripts"];
	NSDictionary *err_info = nil;
	MAIN_SCRIPT = [[OSAScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]
														  error:&err_info];
	if (err_info) {
		NSLog([err_info description]);
		NSRunAlertPanel(nil, @"Fail to load FinderController.scpt", @"OK", nil, nil);
		[NSApp terminate:self];
	}
}

@end
