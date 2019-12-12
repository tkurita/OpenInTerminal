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

@interface PreferencesWindowController ()

@end

static PreferencesWindowController* sharedPrefWindow = nil;
NSString *const kPreferenceGlobalShortcut = @"GlobalShortcut";

@implementation PreferencesWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    self.shortcutView.associatedUserDefaultsKey = kPreferenceGlobalShortcut;
    [self.shortcutView addObserver:self forKeyPath:@"recording"
                           options:NSKeyValueObservingOptionNew context:@""];
    //[self bind:@"recording" toObject:self.shortcutView withKeyPath:@"recording" options:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context
{
    NSLog(@"observeValueForKeyPath");
    if ([keyPath isEqualToString:@"recording"]) {
        [AppController sharedAppController].inhibitAction = [change[NSKeyValueChangeNewKey] boolValue];;
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

-(void)windowWillClose:(NSNotification *)notification
{
    if (self == sharedPrefWindow) {
        sharedPrefWindow = nil;
    }
}

@end
