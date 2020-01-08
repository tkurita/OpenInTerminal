//
//  PreferencesWindowController.h
//  Open in Terminal
//
//  Created by 栗田 哲郎 on 2019/12/11.
//

#import <Cocoa/Cocoa.h>
#import "MASShortcutView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PreferencesWindowController : NSWindowController

@property (nonatomic, weak) IBOutlet MASShortcutView *shortcutView;
@property (nonatomic, strong) id loginItem;

+ (PreferencesWindowController *)sharedPreferencesWindow;

@end

extern NSString *const kPreferenceGlobalShortcut;
NS_ASSUME_NONNULL_END
