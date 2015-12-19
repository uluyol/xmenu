#import <AppKit/NSView.h>
#import "items.h"

@interface XmenuMainView : NSView

@property ItemList itemList;

- (id)initWithFrame:(NSRect)frame items:(ItemList)itemList;
- (void)keyUp:(NSEvent*)event;
- (void)keyDown:(NSEvent*)event;

@end

@interface BorderlessWindow : NSWindow {}
@end
