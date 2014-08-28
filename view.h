#import <AppKit/NSView.h>
#import "items.h"

@interface XmenuMainView : NSView

@property ItemList itemList;

- (id)initWithFrame:(NSRect)frame items:(ItemList)itemList;

@end
