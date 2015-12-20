#pragma once

#include <CoreGraphics/CoreGraphics.h>
#include <stdbool.h>

typedef struct {
  CGColorRef nbg;
  CGColorRef nfg;
  CGColorRef sbg;
  CGColorRef sfg;
  CTFontRef font;
  CGFloat font_siz;
  CGFloat x;
  CGFloat h;
  CGFloat w;
  bool sel;
} DrawCtx;

void initDraw();

bool drawText(CGContextRef ctx, DrawCtx *drawCtx, CFStringRef itemName,
              bool sel);
void drawInput(CGContextRef ctx, DrawCtx *drawCtx, CFStringRef input);
CGColorRef mkColor(char *hex_color);
CFAttributedStringRef mkAttrString(DrawCtx *drawCtx, CFStringRef str,
                                   CGColorRef color);