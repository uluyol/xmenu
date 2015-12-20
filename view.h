#pragma once

@import AppKit;

#include "items.h"

typedef struct _PrevStack {
  CFIndex idx;
  struct _PrevStack *prev;
} PrevStack;

@interface XmenuMainView : NSView

@property ItemList itemList;
@property CFMutableStringRef curText;
@property PrevStack *ps;

- (id)initWithFrame:(NSRect)frame items:(ItemList)itemList;
- (void)keyUp:(NSEvent *)event;
- (void)keyDown:(NSEvent *)event;

@end

@interface BorderlessWindow : NSWindow {
}
@end
