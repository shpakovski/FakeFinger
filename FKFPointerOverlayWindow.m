#import "FKFPointerOverlayWindow.h"

@implementation FKFPointerOverlayWindow

- (instancetype)init
{
    NSImage *image = [NSImage imageNamed:@"Up"];
    CGRect contentRect = (CGRect){ .size = image.size };
    self = [self initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    if (self) {
        self.alphaValue = 0.8;
        self.opaque = NO;
        self.level = NSStatusWindowLevel;
        self.ignoresMouseEvents = YES;
        [self updatePicture];
    }
    return self;
}

#pragma mark - Public API

- (void)updateLocation
{
	NSPoint location = [NSEvent mouseLocation];
    CGRect pointerRect = self.frame;
    pointerRect.origin.x = location.x - CGRectGetWidth(pointerRect) / 2.0;
    pointerRect.origin.y = location.y - CGRectGetWidth(pointerRect) / 2.0;
    self.frameOrigin = pointerRect.origin;
}

- (void)setPressed:(BOOL)pressed
{
    if (_pressed != pressed) {
        _pressed = pressed;
        [self updatePicture];
    }
}

#pragma mark - Private API

- (void)updatePicture
{
    self.backgroundColor = [NSColor colorWithPatternImage:[NSImage imageNamed:(self.pressed ? @"Down": @"Up")]];
}

@end
