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
@property (nonatomic,strong) SMTextContainer *container;
@property (nonatomic,strong) NSAttributedString *text;
@end

@implementation SMTextLayout
+ (instancetype)SM_layoutWithContainer:(SMTextContainer *)container text:(NSAttributedString *)text {
    
    if (!text || !container) return nil;
    
    
    
    SMTextLayout *layout = [[SMTextLayout alloc] init];
    layout.container = container;
    layout.text = text.mutableCopy;
    return layout;
}


#pragma mark - Draw
- (void)SM_drawInContext:(CGContextRef)context
                 size:(CGSize)size
                point:(CGPoint)point
               cancel:(BOOL (^)(void))cancel {
    
    if ((cancel && cancel()) || !context) return;
    SMTextDrawText(context, self, size, point, cancel);
}


static void SMTextDrawText(CGContextRef context, SMTextLayout *layout, CGSize size, CGPoint point,  BOOL (^cancel)(void)) {
    
    CGContextSaveGState(context); {
        CGContextTranslateCTM(context, point.x, point.y);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
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
