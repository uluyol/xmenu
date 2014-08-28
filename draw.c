#import <ApplicationServices/ApplicationServices.h>
#import "draw.h"

#define INPUT_SPACE_FRACTION 0.3

bool
drawText(CGContextRef ctx, DrawCtx *drawCtx, CFStringRef itemName, bool sel)
{
	CGColorRef fg, bg;
	if (sel) {
		fg = drawCtx->sfg;
		bg = drawCtx->sbg;
	} else {
		fg = drawCtx->nfg;
		bg = drawCtx->nbg;
	}
	CFAttributedStringRef attrItemName = mkAttrString(drawCtx, itemName, fg);
	CTLineRef line = CTLineCreateWithAttributedString(attrItemName);
	CGFloat w = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
	if ((drawCtx->x + w) > drawCtx->w)
		return false;
	CGContextSetFillColorWithColor(ctx, bg);
	CGContextFillRect(ctx, CGRectMake (drawCtx->x, 0, w, drawCtx->h));
	CGFloat y = (drawCtx->h - drawCtx->font_siz) / 2;
	CGContextSetTextPosition(ctx, drawCtx->x, y);
	CTLineDraw(line, ctx);
	drawCtx->x += w;
	CFRelease(line);
	CFRelease(attrItemName);
	return true;
}

/* TODO: Actually draw. */
void
drawInput(CGContextRef ctx, DrawCtx *drawCtx) {
	CGFloat w = drawCtx->w * INPUT_SPACE_FRACTION;
	drawCtx->x += w;
}

CFAttributedStringRef
mkAttrString(DrawCtx *drawCtx, CFStringRef str, CGColorRef color) {
	CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName };
	CFTypeRef values[] = { drawCtx->font, color };
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
	rgba[3] = 1.0;
	return CGColorCreate(CGColorSpaceCreateDeviceRGB(), rgba);
}
