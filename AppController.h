#import <Cocoa/Cocoa.h>
#import "Sparkle/SUUpdater.h"

@interface AppControlScript : NSObject
- (void)setup;
- (NSDictionary *)processForContext;
- (NSDictionary *)serviceForPathes:(NSArray *)array;
@end

@interface AppController : NSObject {
	IBOutlet AppControlScript *controlScript;
}
@property (nonatomic, weak) IBOutlet SUUpdater *updater;
@property(assign) BOOL forceQuit;
@property(assign) BOOL inhibitAction;
+ (AppController *)sharedAppController;

@end
