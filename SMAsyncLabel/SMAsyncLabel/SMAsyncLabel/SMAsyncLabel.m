//
//  SMAsyncLabel.m
//  SMAsyncLabel
//
//  Created by simon on 16/11/25.
//  Copyright © 2016年 simon. All rights reserved.
//

#import "SMAsyncLabel.h"
#import "SMAsyncLayer.h"


@interface SMAsyncLabel () <SMLayerDelegate>
/// make the NSAttributedString -> NSMutableAttributedString for using addAttributemethod  or removeAttribute
@property (nonatomic, copy) NSMutableAttributedString *attrs;
/// if has textLayout, then no need layout
@property (nonatomic, assign) BOOL layoutNeedUpdate;

@end

@implementation SMAsyncLabel
#pragma mark - Override
+ (Class)layerClass {
    return SMAsyncLayer.class;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        [self setupLabel];
    }
    
    return self;
}

- (void)setupLabel {
    self.layer.contentsScale = [UIScreen mainScreen].scale;
    self.contentMode = UIViewContentModeRedraw;
    
    _font = [UIFont systemFontOfSize:15.0f];
    _layoutNeedUpdate = YES;
}


#pragma mark - SMLayerDelegate
- (SMLayerDisplayTask *)displayTask {
    
    SMLayerDisplayTask *task = [[SMLayerDisplayTask alloc] init];
   
    // remove attachment
    task.willDisplay = ^(CALayer *layer) {
        
    };
    
    task.display = ^(CGContextRef context, CGSize size, BOOL (^isCancelled)(void)) {
        NSLog(@"%i", self.layoutNeedUpdate);
        if (self.layoutNeedUpdate) {
            SMTextContainer *textContainer = [SMTextContainer sm_textContainerWithSize:self.frame.size];
            _textLayout = [SMTextLayout sm_layoutWithContainer:textContainer text:_attrs];
        }
       
        CGPoint point = CGPointZero;
        
        [_textLayout sm_drawInContext:context size:_textLayout.size point:point cancel:isCancelled];
    };
    
    // remove attachment, animation
    task.didEndDisplay = ^(CALayer *layer, BOOL finished) {
        
    };
    
    
    return task;
}

#pragma mark - Setter
- (void)setText:(NSString *)text {
    if (!text || _text == text) return;
    _text = text.copy;
    
    _attrs = [[NSMutableAttributedString alloc] initWithString:_text attributes:nil];
    
    NSRange range = NSMakeRange(0, _attrs.length);
    [_attrs setFont:_font range:range];
    
    if (_textColor) {
        NSRange range = NSMakeRange(0, _attrs.length);
        [self.attrs setTextColor:_textColor range:range];
    }
    
    [self.layer setNeedsDisplay];
}


- (void)setAttributedText:(NSMutableAttributedString *)attributedText {
    if (attributedText.length <=0 || _attributedText == attributedText) return;
    
    _attrs = attributedText.mutableCopy;
    
    [self.layer setNeedsDisplay];
}

- (void)setFont:(UIFont *)font {
    if (!font) font = [UIFont systemFontOfSize:17];
    _font = font;
    
    if (_attrs.length) {
        NSRange range = NSMakeRange(0, _attrs.length);
        [_attrs setFont:_font range:range];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    if (!textColor) textColor = [UIColor blackColor];
    
    if (_textColor == textColor || [_textColor isEqual:textColor]) return;
    _textColor = textColor;
    NSRange range = NSMakeRange(0, _attrs.length);
    [self.attrs setTextColor:_textColor range:range];
}

- (void)setTextLayout:(SMTextLayout *)textLayout {
    if (_textLayout == textLayout) return;
    _textLayout = textLayout;
    _layoutNeedUpdate = NO;
    [self.layer setNeedsDisplay];
}

- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth {
    if (_preferredMaxLayoutWidth == preferredMaxLayoutWidth) return;
    _preferredMaxLayoutWidth = preferredMaxLayoutWidth;
     [self invalidateIntrinsicContentSize];
}

- (void)setNumberOfLines:(NSUInteger)numberOfLines {
//    if (_numberOfLines == numberOfLines) return;
    _numberOfLines = numberOfLines;

    if (_attrs.length) {
        [self.layer setNeedsDisplay];
        [self invalidateIntrinsicContentSize];
    }
}
- (CGSize)intrinsicContentSize {
    if (_preferredMaxLayoutWidth == 0) {
        return CGSizeZero;
    }
    
    CGSize containerSize;
    containerSize.height = CGFLOAT_MAX;
    containerSize.width = _preferredMaxLayoutWidth;
    if (containerSize.width == 0) containerSize.width = self.bounds.size.width;
    
    
    SMTextContainer *textContainer = [SMTextContainer sm_textContainerWithSize:self.frame.size];
    
    SMTextLayout *layout = [SMTextLayout sm_layoutWithContainer:textContainer text:_attrs];
    return layout.size;
}
@end


@implementation NSMutableAttributedString (SMText)

- (void)setFont:(UIFont *)font range:(NSRange)range {
    [self setAttribute:NSFontAttributeName value:font range:range];
}

- (void)setTextColor:(UIColor *)textColor range:(NSRange)range {
    [self setAttribute:NSForegroundColorAttributeName value:textColor range:range];
}

- (void)setAttribute:(NSString *)name value:(id)value range:(NSRange)range {
    if (!name || [NSNull isEqual:name]){
        return;
    }
    if (value && ![NSNull isEqual:value]) {
        [self addAttribute:name value:value range:range];
    }else {
        [self removeAttribute:name range:range];
    }
}

- (void)removeAttributesInRange:(NSRange)range {
    [self setAttributes:nil range:range];
}

@end
