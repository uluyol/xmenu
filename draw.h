#import <CoreGraphics/CoreGraphics.h>

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
} DrawCtx;

bool drawText(CGContextRef ctx, DrawCtx *drawCtx, CFStringRef itemName);
CGColorRef mkColor(char *hex_color);
CFAttributedStringRef mkAttrString(DrawCtx *drawCtx, CFStringRef str);