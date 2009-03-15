#import "AccelerometerHelper.h"

#define UNDEFINED_VALUE		999.99f

@implementation AccelerometerHelper
@synthesize sensitivity;
@synthesize lockout;
@synthesize triggerTime;

static AccelerometerHelper *sharedInstance = nil;

+(AccelerometerHelper *) sharedInstance {
    if(!sharedInstance) sharedInstance = [[self alloc] init];
    return sharedInstance;
}

- (id) init
{
	if (!(self = [super init])) return self;
	
	self.triggerTime = [NSDate date];
	
	lx = UNDEFINED_VALUE;
	ly = UNDEFINED_VALUE;
	lz = UNDEFINED_VALUE;

	px = UNDEFINED_VALUE;
	py = UNDEFINED_VALUE;
	pz = UNDEFINED_VALUE;
	
	cx = UNDEFINED_VALUE;
	cy = UNDEFINED_VALUE;
	cz = UNDEFINED_VALUE;
	
	self.sensitivity = 0.5f;
	self.lockout = 0.5f;
	
	return self;
}

- (void) setX: (float) aValue
{
	lx = px;
	px = cx;
	cx = aValue;
}

- (void) setY: (float) aValue
{
	ly = py;
	py = cy;
	cy = aValue;
}

- (void) setZ: (float) aValue
{
	lz = pz;
	pz = cz;
	cz = aValue;
}

- (float) dotValue
{
	if (lx == UNDEFINED_VALUE) return UNDEFINED_VALUE;
	if (px == UNDEFINED_VALUE) return UNDEFINED_VALUE;
	if (cx == UNDEFINED_VALUE) return UNDEFINED_VALUE;
	
	// Calculate the dot product of the first pair
	float dot1 = cx * px + cy * py + cz * pz;
	float a = ABS(sqrt(cx * cx + cy * cy + cz * cz));
	float b = ABS(sqrt(px * px + py * py + pz * pz));
	dot1 /= (a * b);
	
	// Calculate the dot product of the second pair
	float dot2 = px * lx + py * ly + pz * lz;
	a = ABS(sqrt(lx * lx + ly * ly + lz * lz));
	dot2 /= a * b;

	// Return the difference between the two dot products
	return ABS(dot1 - dot2);
}

- (BOOL) checkTrigger
{
	if (lx == UNDEFINED_VALUE) return NO;
	
	// Check to see if the new data can be triggered
	if ([[NSDate date] timeIntervalSinceDate:self.triggerTime] < self.lockout) return NO;
	
	// Get the current dot product
	float dot = [self dotValue];
	
	// If we have not yet gathered two samples, return NO
	if (dot == UNDEFINED_VALUE) return NO;
	
	// Check to see if the dot product falls below the trigger sensitivity
	if (dot > self.sensitivity)
	{
		self.triggerTime = [NSDate date];
		return YES;
	}
	else return NO;
}

@end
