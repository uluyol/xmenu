#import <AppKit/NSView.h>
#import "items.h"

@interface XmenuMainView : NSView

@property ItemList itemList;

- (id)initWithFrameAndItems:(NSRect)frame Items:(ItemList)itemList;

@end
