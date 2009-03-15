#import <UIKit/UIKit.h>

@interface AccelerometerHelper : NSObject {
	float	cx, cy, cz;
	float	px, py, pz;
	float	lx, ly, lz;
	
	float	sensitivity;
	
	NSDate	*triggerTime;
	NSTimeInterval lockout;
}

+ (AccelerometerHelper *) sharedInstance;

- (BOOL) checkTrigger;
- (float) dotValue;
- (void) setX: (float) x;
- (void) setY: (float) y;
- (void) setZ: (float) z;

@property (nonatomic, retain)	NSDate *triggerTime;
@property (nonatomic)	float sensitivity;
@property (nonatomic)	NSTimeInterval lockout;
@end
