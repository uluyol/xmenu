#import <Cocoa/Cocoa.h>
#import "draw.h"
#include <string.h>

#define prompt_s "$"

@implementation XmenuMainView
- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame: frame];
	return self;
}

- (void)drawRect:(NSRect)rect
{
	DrawCtx drawCtx;
	drawCtx.nbg = mkColor("#ffffff");
	drawCtx.sbg = mkColor("#f00");
	drawCtx.nfg = mkColor("#0F0");
	drawCtx.sfg = mkColor("#00f");
	drawCtx.x = 0;
	drawCtx.font_siz = 14.0; // TODO: Fix shadows
	[[NSColor colorWithCGColor: drawCtx.nbg] set];
	NSRectFill(rect);
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];

	CFStringRef itemName = CFStringCreateWithCString(NULL, " Test String ", kCFStringEncodingUTF8);
	CFStringRef psFont = CFStringCreateWithCString(NULL, "Consolas", kCFStringEncodingUTF8);
	CTFontDescriptorRef fontDesc = CTFontDescriptorCreateWithNameAndSize(psFont, drawCtx.font_siz);
	CTFontRef font = CTFontCreateWithFontDescriptor(fontDesc, 0.0, NULL);
	drawCtx.font = font;
	drawCtx.h = rect.size.height;
	drawCtx.w = rect.size.width;
	while (drawText(ctx, &drawCtx, itemName));
//	CFRelease(itemName);
//	CFRelease(attrs);
}

@end

bool
drawText(CGContextRef ctx, DrawCtx *drawCtx, CFStringRef itemName)
{
	CFAttributedStringRef attrItemName = mkAttrString(drawCtx, itemName);
	CTLineRef line = CTLineCreateWithAttributedString(attrItemName);
	CGRect lineRect = CTLineGetImageBounds(line, ctx);
	CGFloat h = CGRectGetHeight(lineRect);
	CGFloat w = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
	CGFloat y = (drawCtx->h + drawCtx->font_siz) / 2 - h;
	if ((drawCtx->x + w) > drawCtx->w)
		return false;
	CGContextSetFillColorWithColor(ctx, drawCtx->sbg);
	CGContextFillRect(ctx, CGRectMake (drawCtx->x, 0, w, drawCtx->h));
	CGContextSetTextPosition(ctx, drawCtx->x, y);
	CTLineDraw(line, ctx);
	drawCtx->x += w;
	CFRelease(line);
	CFRelease(attrItemName);
	return true;
}

CFAttributedStringRef
mkAttrString(DrawCtx *drawCtx, CFStringRef str) {
	CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName };
	CFTypeRef values[] = { drawCtx->font, drawCtx->sfg };
	CFDictionaryRef attrs = CFDictionaryCreate(
		kCFAllocatorDefault,
		(const void **)&keys,
		(const void **)&values,
		sizeof keys / sizeof(CFStringRef),
		&kCFTypeDictionaryKeyCallBacks,
		&kCFTypeDictionaryValueCallBacks);
	return CFAttributedStringCreate(kCFAllocatorDefault, str, attrs);
}

CGColorRef
mkColor(char *hex_color)
{
	if (!hex_color || *hex_color != '#')
		return NULL;
	hex_color++;
	CGFloat rgba[4];
	rgba[3] = 1.0;
	int t;
	switch (strlen(hex_color)) {
	case 3:
		if (1 != sscanf(hex_color, "%3x", &t))
			return NULL;
		rgba[0] = (t >> 8) | ((t >> 4) & 0xF0);
		rgba[1] = ((t >> 4) & 0xF) | (t & 0xF0);
		rgba[2] = (t & 0xF) | ((t << 4) & 0xF0);
		break;
	case 6:
		if (1 != sscanf(hex_color, "%6x", &t))
			return NULL;
		rgba[0] = (t >> 16) & 0xFF;
		rgba[1] = (t >> 8) & 0xFF;
		rgba[2] = t & 0xFF;
		break;
	default:
		return NULL;
	}
	rgba[0] /= 255.0;
	rgba[1] /= 255.0;
	rgba[2] /= 255.0;
	return CGColorCreate(CGColorSpaceCreateDeviceRGB(), rgba);
}

