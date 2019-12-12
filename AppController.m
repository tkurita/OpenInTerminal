#import "AppController.h"
#import "DonationReminder/DonationReminder.h"
#import "TXFrontAccess.h"
#import "GUIScriptingChecker.h"
#import "PreferencesWindowController.h"
#import "MASShortcut.h"
#import "MASShortcutBinder.h"

#define useLog 1

static BOOL CHECK_UPDATE = NO;

@implementation AppController

/*
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
#if useLog
	NSLog(@"start applicationShouldTerminate");
#endif
    if (_forceQuit) {return NSTerminateNow;}
    
    NSAppleEventDescriptor *ev = [ [NSAppleEventManager sharedAppleEventManager] currentAppleEvent];
    #if useLog
        NSLog(@"%@", [ev description]);
    #endif
    if (ev) { // quit event of AppleEvent
        if (kAEQuitApplication ==  [ev eventID] ) {
            return NSTerminateNow;
        }
    } else {
        return NSTerminateNow;
    }
    
    return NSTerminateCancel;
}
*/

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
#if useLog
	NSLog(@"start applicationShouldTerminateAfterLastWindowClosed");
#endif
    return NO;
}

- (void)checkUpdate
{
    #if useLog
        NSLog(@"%@", @"start checkUpdate");
    #endif
    [updater checkForUpdatesInBackground];
    /*
    if (STAY_RUNNING) {
        [updater checkForUpdatesInBackground];
	} else {
		[updater checkForUpdates:self];
	}
     */
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

void displayErrorDict(NSDictionary *errdict)
{
    int error_no = [(NSNumber *)errdict[@"number"] intValue];
    if (error_no) {
        [[NSAlert alertWithError:[NSError errorWithDomain:@"OpenInTerminalErrorDomain"
                                                     code:errno
                                                 userInfo:@{NSLocalizedDescriptionKey:errdict[@"message"]}]]
         runModal];
    }
}

- (void)processForLaunched
{
    #if useLog
        NSLog(@"%@", @"start processForLaunched");
    #endif
	NSDictionary *errdict = [controlScript processForContext];
    displayErrorDict(errdict);
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
	NSInteger interval_count = [user_defaults integerForKey:@"UpdateIntervalLaunchCounts"];
	NSInteger current_count = [user_defaults integerForKey:@"CurrentLaunchCount"];
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
    NSLog(@"front app id : %@ in applicationDidFinishLaunching", [[TXFrontAccess frontAccessForFrontmostApp] bundleIdentifier]);
#endif
    
    [[MASShortcutBinder sharedBinder]
        bindShortcutWithDefaultsKey:kPreferenceGlobalShortcut
        toAction:^{
        if (!self.inhibitAction) {
            [self processForLaunched];
        }
    }];
    
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
	NSDictionary *errdict = [controlScript serviceForPathes:filenames];
    displayErrorDict(errdict);
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
    [NSApp deactivate]; // does not work
    [[NSRunningApplication currentApplication] hide];
#if useLog
    NSLog(@"front app id : %@ in processForFrontContextFromPasteboard", [[TXFrontAccess frontAccessForFrontmostApp] bundleIdentifier]);
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
    NSLog(@"front app id : %@ in applicationOpenUntitledFile", [[TXFrontAccess frontAccessForFrontmostApp] bundleIdentifier]);
#endif
    PreferencesWindowController *prefwin = [PreferencesWindowController sharedPreferencesWindow];
    [prefwin showWindow:self];
	return YES;
}

- (void)awakeFromNib
{
#if useLog
	NSLog(@"awakeFromNib");
    NSLog(@"front app id : %@ in awakeFromNib", [[TXFrontAccess frontAccessForFrontmostApp] bundleIdentifier]);
#endif
	/* Setup User Defaults */
	NSString *defaults_plist = [[NSBundle mainBundle] pathForResource:@"FactorySettings"
															   ofType:@"plist"];
	NSDictionary *factory_defaults = [NSDictionary dictionaryWithContentsOfFile:defaults_plist];
	
	NSUserDefaults *user_defaults = [NSUserDefaults standardUserDefaults];
	[user_defaults registerDefaults:factory_defaults];
    self.inhibitAction = NO;
	/* Setup Services Menu */
	[NSApp setServicesProvider:self];
}

//MARK: methods for singleton
static AppController *sharedInstance = nil;

+ (AppController *)sharedAppController
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        (void)[[AppController alloc] init];
    });
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    
    __block id ret = nil;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [super allocWithZone:zone];
        ret = sharedInstance;
    });
    
    return  ret;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
