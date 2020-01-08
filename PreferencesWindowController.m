//
//  PreferencesWindowController.m
//  Open in Terminal
//
//  Created by 栗田 哲郎 on 2019/12/11.
//

#import "PreferencesWindowController.h"
#import "MASShortcutBinder.h"
#import "MASShortcutView+Bindings.h"
#import "AppController.h"
#import "LLManager.h"
#import "DateStringTransformer.h"

@interface PreferencesWindowController ()

@end

static PreferencesWindowController* sharedPrefWindow = nil;
NSString *const kPreferenceGlobalShortcut = @"GlobalShortcut";

@implementation PreferencesWindowController

+ (void)initialize    // Early initialization
{
    if ([PreferencesWindowController class] == self) {
        [NSValueTransformer setValueTransformer:[DateStringTransformer new] forName:@"DateStringTrasformer"];
    }
}

- (void)windowDidLoad {
    [super windowDidLoad];
    self.shortcutView.associatedUserDefaultsKey = kPreferenceGlobalShortcut;
    [self.shortcutView addObserver:self forKeyPath:@"recording"
                           options:NSKeyValueObservingOptionNew context:@""];
}

- (BOOL)launchAtLogin
{
    BOOL result = [LLManager launchAtLogin];
    return result;
}

- (void)setLaunchAtLogin:(BOOL)state
{
    [LLManager setLaunchAtLogin:state];
}

- (IBAction)launchAtLoginCheckboxAction:(NSButton *)launchAtLoginCheckbox {
    switch (launchAtLoginCheckbox.state) {
        case NSOnState:     [LLManager setLaunchAtLogin:YES]; break;
        case NSOffState:    [LLManager setLaunchAtLogin:NO]; break;
    }
}

+ (PreferencesWindowController *)sharedPreferencesWindow
{
    if (!sharedPrefWindow) {
        sharedPrefWindow = [[self alloc] initWithWindowNibName:@"PreferencesWindow"];
    }
    return sharedPrefWindow;
}

- (void)awakeFromNib
{
    [[self window] center];
    [self setWindowFrameAutosaveName:@"PreferencesWindow"];
}

- (void)windowWillClose:(NSNotification *)notification
{
    if (self == sharedPrefWindow) {
        sharedPrefWindow = nil;
    }
}

@end
