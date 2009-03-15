#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <math.h>
#import "AccelerometerHelper.h"

#define MAIN_VIEW	999
#define	SENSITIVITY_SLIDER	11
#define	TIME_SLIDER	12
#define	SENSITIVITY_TEXT	101
#define TIME_TEXT	102
#define MAIN_TEXT_VIEW	13
#define ACCEL_LABEL	14

@interface HelloController : UIViewController <UIAccelerometerDelegate>
{
	UIImageView *contentView;
	BOOL isChange;
	SystemSoundID snd;
}
@end

@implementation HelloController
- (id)init
{
	if (!(self = [super init])) return self;
	
	id sndpath = [[NSBundle mainBundle] pathForResource:@"whoosh" ofType:@"aif" inDirectory:@"/"];
	CFURLRef baseURL = (CFURLRef)[[NSURL alloc] initFileURLWithPath:sndpath];
	AudioServicesCreateSystemSoundID (baseURL, &snd);

	return self;
}

- (void) playSound

{
	AudioServicesPlaySystemSound (snd);
}


- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	[[AccelerometerHelper sharedInstance] setX:-[acceleration x]];
	[[AccelerometerHelper sharedInstance] setY: [acceleration y]];
	[[AccelerometerHelper sharedInstance] setZ: [acceleration z]];
	
	float dot = [[AccelerometerHelper sharedInstance] dotValue];
	[(UILabel *)[self.view viewWithTag:ACCEL_LABEL] setText:[NSString stringWithFormat:@"%4.2f", dot]];
	
	if ([[AccelerometerHelper sharedInstance] checkTrigger])
	{
		[(UITextView *)[self.view viewWithTag:MAIN_TEXT_VIEW] 
		 setText:[NSString stringWithFormat:@"Triggered at: %4.2f", [[AccelerometerHelper sharedInstance] dotValue]]];
		[self playSound];
	}
}

- (void) updateSensitivity: (UISlider *) slider
{
	float sensitivity = [slider value];
	[(UITextField *)[self.view viewWithTag:SENSITIVITY_TEXT] setText:[NSString stringWithFormat:@"%4.2f", sensitivity]];
	[[AccelerometerHelper sharedInstance] setSensitivity:sensitivity];
}

- (void) updateTimeLockout: (UISlider *) slider
{
	float timeout = [slider value];
	[(UITextField *)[self.view viewWithTag:TIME_TEXT] setText:[NSString stringWithFormat:@"%4.2f", timeout]];
	[[AccelerometerHelper sharedInstance] setLockout:timeout];
}

- (void)loadView
{
	NSArray *niblets = [[NSBundle mainBundle] loadNibNamed:@"AccelFeedbackView" owner:self options:NULL];

	id found = nil;
	for (id theObject in niblets) 
		if ([theObject isKindOfClass:[UIView class]])
			if ([theObject tag] == MAIN_VIEW)
				found = theObject;
	if (!found) return;
	self.view = found;
	
	[(UISlider *)[self.view viewWithTag:SENSITIVITY_SLIDER] addTarget:self action:@selector(updateSensitivity:) forControlEvents:UIControlEventValueChanged];
	[(UISlider *)[self.view viewWithTag:TIME_SLIDER] addTarget:self action:@selector(updateTimeLockout:) forControlEvents:UIControlEventValueChanged];
	
	[(UILabel *)[self.view viewWithTag:ACCEL_LABEL] setFont:[UIFont boldSystemFontOfSize:48.0f]];
	
	// Start the accelerometer going
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
}

-(void) dealloc
{
	if (snd) AudioServicesDisposeSystemSoundID(snd);
	[contentView release];
	[super dealloc];
}
@end


@interface SampleAppDelegate : NSObject <UIApplicationDelegate>
@end

@implementation SampleAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	HelloController *hc = [[HelloController alloc] init];
	[window addSubview:hc.view];
	[window makeKeyAndVisible];
}
@end

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"SampleAppDelegate");
	[pool release];
	return retVal;
}
