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
@property (nonatomic, strong) SMTextLayout *textLayout;
@property (nonatomic, copy) NSMutableAttributedString *attrs;
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
}


#pragma mark - SMLayerDelegate
- (SMLayerDisplayTask *)displayTask {
    
    SMLayerDisplayTask *task = [[SMLayerDisplayTask alloc] init];
    SMTextContainer *textContainer = [SMTextContainer sm_textContainerWithSize:self.frame.size];
    
    // remove attachment
    task.willDisplay = ^(CALayer *layer) {
        
    };
    
    task.display = ^(CGContextRef context, CGSize size, BOOL (^isCancelled)(void)) {
        
        _textLayout = [SMTextLayout sm_layoutWithContainer:textContainer text:_attrs];

        CGPoint point = CGPointZero;
        
        [_textLayout sm_drawInContext:context size:size point:point cancel:isCancelled];
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
        [self.layer setNeedsDisplay];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    if (!textColor) textColor = [UIColor blackColor];
    
    if (_textColor == textColor || [_textColor isEqual:textColor]) return;
    _textColor = textColor;
    NSRange range = NSMakeRange(0, _attrs.length);
    [self.attrs setTextColor:_textColor range:range];
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
