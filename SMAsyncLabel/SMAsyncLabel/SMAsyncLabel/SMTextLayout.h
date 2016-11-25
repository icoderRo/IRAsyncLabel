//
//  SMTextLayout.h
//  SMAsyncLabel <https://github.com/icoderRo/SMAsyncLabel>
//
//  Created by simon on 16/11/24.
//  Copyright © 2016年 simon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMTextContainer.h"

@interface SMTextLayout : NSObject
@property (nonatomic,strong,readonly) SMTextContainer *container;
@property (nonatomic,strong,readonly) NSAttributedString *text;
@property (nonatomic, copy) NSArray *textArray;

+ (instancetype)SM_layoutWithContainer:(SMTextContainer *)container
                                  text:(NSAttributedString *)text;

- (void)SM_drawInContext:(CGContextRef)context
                 size:(CGSize)size
                point:(CGPoint)point
               cancel:(BOOL (^)(void))cancel;
@end
