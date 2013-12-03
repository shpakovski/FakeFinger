/// Finger overlay.
@interface FKFPointerOverlayWindow : NSWindow

/// Shows alternate picture when pressed.
@property (nonatomic, getter = isPressed) BOOL pressed;

/// Moves window to the current cursor location.
- (void)updateLocation;

@end
