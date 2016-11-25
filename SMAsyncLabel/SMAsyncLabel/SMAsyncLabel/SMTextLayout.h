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
+ (instancetype)SM_layoutWithContainer:(SMTextContainer *)container text:(NSAttributedString *)text;
@end
