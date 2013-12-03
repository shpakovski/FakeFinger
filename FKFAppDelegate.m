#import "FKFAppDelegate.h"
#import "FKFPointerOverlayWindow.h"

@interface FKFAppDelegate ()

@property (nonatomic) FKFPointerOverlayWindow *pointerOverlay;

@end

#pragma mark

@implementation FKFAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    self.pointerOverlay = [[FKFPointerOverlayWindow alloc] init];
    [self.pointerOverlay updateLocation];
    [self.pointerOverlay orderFront:nil];

    FKFCreateTapCallbackWithDelegate(self);
    FKFHideCursor();
}

#pragma mark - Private API

- (void)mouseDown
{
    self.pointerOverlay.pressed = YES;
}

- (void)mouseUp
{
    self.pointerOverlay.pressed = NO;
}

- (void)mouseMoved
{
    [self.pointerOverlay updateLocation];
}

- (void)mouseDragged
{
    [self.pointerOverlay updateLocation];
}

#pragma mark - Carbon

void FKFCreateTapCallbackWithDelegate(id delegate)
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGEventMask mask =	(CGEventMaskBit(kCGEventLeftMouseDown) |
                             CGEventMaskBit(kCGEventLeftMouseUp) |
                             CGEventMaskBit(kCGEventLeftMouseDragged) |
                             CGEventMaskBit(kCGEventMouseMoved));
        CFMachPortRef tap = CGEventTapCreate(kCGAnnotatedSessionEventTap,
                                             kCGTailAppendEventTap,
                                             kCGEventTapOptionListenOnly,
                                             mask,
                                             FKFTapCallback,
                                             delegate);
        CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(NULL, tap, 0);
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, kCFRunLoopCommonModes);
        CFRelease(runLoopSource);
        CFRelease(tap);
    });
}

void FKFHideCursor()
{
    // The not so hacky way:
    //    CGDirectDisplayID myId = CGMainDisplayID();
    //    CGDisplayHideCursor(kCGDirectMainDisplay);
    //    BOOL isCursorVisible = CGCursorIsVisible();

    // The hacky way:
    void CGSSetConnectionProperty(int, int, CFStringRef, CFBooleanRef);
    int _CGSDefaultConnection();
    CFStringRef propertyString;

    // Hack to make background cursor setting work
    propertyString = CFStringCreateWithCString(NULL, "SetsCursorInBackground", kCFStringEncodingUTF8);
    CGSSetConnectionProperty(_CGSDefaultConnection(), _CGSDefaultConnection(), propertyString, kCFBooleanTrue);
    CFRelease(propertyString);
    // Hide the cursor and wait
    CGDisplayHideCursor(kCGDirectMainDisplay);
}

CGEventRef FKFTapCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *info)
{
	FKFAppDelegate *delegate = (FKFAppDelegate *)info;
	switch(type)
	{
		case kCGEventLeftMouseDown:
			[delegate mouseDown];
			break;
		case kCGEventLeftMouseUp:
			[delegate mouseUp];
			break;
		case kCGEventLeftMouseDragged:
			[delegate mouseDragged];
			break;
		case kCGEventMouseMoved:
			[delegate mouseMoved];
			break;
	}
    FKFHideCursor();
	return event;
}

@end
