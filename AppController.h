#import <Cocoa/Cocoa.h>
#import "Sparkle/SUUpdater.h"

@interface AppControlScript : NSObject
- (void)setup;
- (void)processForContext;
- (id)serviceForPathes:(NSArray *)array;
@end

@interface AppController : NSObject {
	IBOutlet SUUpdater *updater;
	IBOutlet AppControlScript *controlScript;
}

@end
