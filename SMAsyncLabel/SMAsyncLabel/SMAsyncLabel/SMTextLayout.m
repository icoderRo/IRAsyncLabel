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
    CGPathRef path = container.path.CGPath;
    
//    CTFramesetterCreateFrame(<#CTFramesetterRef  _Nonnull framesetter#>, <#CFRange stringRange#>, <#CGPathRef  _Nonnull path#>, <#CFDictionaryRef  _Nullable frameAttributes#>)
    
    
    
    
    
    // CTLineRef
    
    NSMutableArray *linesArray = [NSMutableArray array];
    
    
    
    
    
    
    
    
    
    
    
    
    
    // CTRunRef
    
    
    
    
    
    
    
    
    // Setter
    SMTextLayout *layout = [[SMTextLayout alloc] init];
    layout->_needDrawText = YES;
    layout->_container = container;
    layout->_text = text.mutableCopy;
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
