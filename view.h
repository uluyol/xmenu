#pragma once

@import AppKit;

#include "items.h"

@interface XmenuMainView : NSView

- (id)initWithFrame:(NSRect)frame
              items:(ItemList)itemList
            drawCtx:(DrawCtx *)drawCtx
          promptStr:(CFStringRef)promptStr;
- (void)keyUp:(NSEvent *)event;
- (void)keyDown:(NSEvent *)event;

@end

@interface BorderlessWindow : NSWindow
@end
