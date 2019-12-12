#import <Cocoa/Cocoa.h>
#import "Sparkle/SUUpdater.h"

@interface AppControlScript : NSObject
- (void)setup;
- (NSDictionary *)processForContext;
- (NSDictionary *)serviceForPathes:(NSArray *)array;
@end

@interface AppController : NSObject {
	IBOutlet SUUpdater *updater;
	IBOutlet AppControlScript *controlScript;
}
@property(assign) BOOL forceQuit;
@property(assign) BOOL inhibitAction;
+ (AppController *)sharedAppController;

@end
