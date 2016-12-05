//
//  SMTextLayout.m
//  SMAsyncLabel <https://github.com/icoderRo/SMAsyncLabel>
//
//  Created by simon on 16/11/24.
//  Copyright © 2016年 simon. All rights reserved.
//

#import "SMTextLayout.h"
#import <CoreText/CoreText.h>

@interface SMTextLayout ()
//@property (nonatomic,strong) SMTextContainer *container;
//@property (nonatomic,strong) NSAttributedString *text;

@end

@implementation SMTextLayout
#pragma mark - Init
+ (instancetype)sm_layoutWithContainer:(SMTextContainer *)container text:(NSAttributedString *)text {
    
    if (!text || !container) return nil;
    
    // CTFrameRef
    NSMutableAttributedString *attText = text.mutableCopy;
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFTypeRef)attText);
    CFRange range = CFRangeMake(0, (CFIndex)attText.length);
    CGPathRef containerPath = container.path.CGPath;
    CGRect boundingBox = CGPathGetBoundingBox(containerPath);
    
    // calculate  bounding size
    CGSize constraints = CGSizeMake(boundingBox.size.width, MAXFLOAT);
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, range, NULL, constraints, NULL);
    CGSize size = CGSizeMake(ceil(suggestSize.width), ceil(suggestSize.height));
    
    // addRect
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect rect = {boundingBox.origin,{boundingBox.size.width, size.height}};
    CGPathAddRect(path, NULL, rect);
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, range, path, NULL);
    
    
    // CTLineRef
    int rowIndex = -1;
    int rowCount = 0;
    int curIndex = 0;
    
    CGRect lastRect = CGRectMake(0.0f, -CGFLOAT_MAX, 0.0f, 0.0f);
    CGPoint lastPos = CGPointMake(0.0f, -CGFLOAT_MAX);
    CGRect textBoundRect = CGRectZero;
    
    NSMutableArray *linesArray = [NSMutableArray array];
    
    CFArrayRef ctLines = CTFrameGetLines(frame);
    CFIndex lineCount = CFArrayGetCount(ctLines);
    CGPoint *lineOrigins = NULL;
    if (lineCount > 0) {
        lineOrigins = malloc(lineCount *sizeof(CGPoint));
        CTFrameGetLineOrigins(frame, CFRangeMake(0, lineCount), lineOrigins);
    }
    
    for (int i = 0; i < lineCount; i++) {
        
        CTLineRef ctLine = CFArrayGetValueAtIndex(ctLines, i);
        CFArrayRef runs = CTLineGetGlyphRuns(ctLine);
        CFIndex run = CFArrayGetCount(runs);
        if (!runs || run == 0) continue;
        
        CGPoint lineOrigin = lineOrigins[i];
        CGPoint position = CGPointMake(rect.origin.x + lineOrigin.x, rect.size.height + rect.origin.y - lineOrigin.y);
        
        SMTextLine *line = [SMTextLine sm_textLineWithCTLine:ctLine lineOrigin:position];
        CGRect lineRect = line.frame;
        
        BOOL newRow = YES;
        if (position.x != lastPos.x) {
            if (lineRect.size.height > lastRect.size.height) {
                if (lineRect.origin.y < lastPos.y && lastPos.y < lineRect.origin.y + lineRect.size.height) {
                    newRow = NO;
                }
            } else {
                if (lastRect.origin.y < position.y && position.y < lastRect.origin.y + lastRect.size.height) {
                    newRow = NO;
                }
            }
        }
        if (newRow){
            rowIndex ++;
        }
        
        lastRect = lineRect;
        lastPos = position;
        line.index = curIndex;
        line.row = rowIndex;
        [linesArray addObject:line];
        
        rowCount = rowIndex + 1;
        curIndex += 1;
        if (i == 0) {
            textBoundRect = lineRect;
        } else {
            textBoundRect = CGRectUnion(textBoundRect, lineRect);
        }
    }

    // Setter
    SMTextLayout *layout = [[SMTextLayout alloc] init];
    layout->_needDrawText = YES;
    layout->_container = container;
    layout->_text = text.mutableCopy;
    layout->_linesArray = linesArray;
    layout->_size = size;
    // TODO: setting more ....
    
    CFRelease(frameSetter);
    CFRelease(frame);
    CFRelease(path);
    if (lineOrigins) free(lineOrigins);
    return layout;
}

#pragma mark - Draw
- (void)sm_drawInContext:(CGContextRef)context
                 size:(CGSize)size
                point:(CGPoint)point
               cancel:(BOOL (^)(void))cancel {
    
    
    
    if (self.needDrawText && context) {
        if (cancel && cancel()) return;
        SMTextDrawText(self, context, size, point, cancel);
//        SMTextDrawFrameText(context, self, size, point, cancel);

    }
}

static void SMTextDrawText(SMTextLayout *layout, CGContextRef context, CGSize size, CGPoint point,  BOOL (^cancel)(void)) {
    CGContextSaveGState(context); {
        
        CGContextTranslateCTM(context, point.x, point.y);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1, -1);
        
        for (SMTextLine *line in layout.linesArray) {
            if (cancel && cancel()) break;
            
            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
            CGContextSetTextPosition(context, line.lineOrigin.x, size.height - line.lineOrigin.y);
            
            CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
            
            for (int i = 0; i < CFArrayGetCount(runs); i++) {
                if (cancel && cancel()) break;
                
                CTRunRef run = CFArrayGetValueAtIndex(runs, i);
                CTRunDraw(run, context, CFRangeMake(0, 0));
            }
        }
    } CGContextRestoreGState(context);
}


// test
static void SMTextDrawFrameText(CGContextRef context, SMTextLayout *layout, CGSize size, CGPoint point,  BOOL (^cancel)(void)) {
    
    CGContextSaveGState(context); {
        CGContextTranslateCTM(context, point.x, point.y);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        
        CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat components[] = {1.0, 0.0, 0.0, 0.8};
        CGColorRef red = CGColorCreate(rgbColorSpace, components);
        CGColorSpaceRelease(rgbColorSpace);
        
        CFRange cfRange = CFRangeMake(0, (CFIndex)[layout.text length]);
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)layout.text, cfRange, kCTBackgroundColorAttributeName, red);

        CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFTypeRef)layout.text);
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(point.x, point.y, size.width, size.height));
        
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, cfRange, path, NULL);
        
        CTFrameDraw(frame, context);
        
        CFRelease(path);
        CFRelease(frameSetter);
        CFRelease(frame);
        
    } CGContextRestoreGState(context);
}
@end
