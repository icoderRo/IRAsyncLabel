//
//  ViewController.m
//  SMAsyncLabel
//
//  Created by simon on 16/11/24.
//  Copyright © 2016年 simon. All rights reserved.
//

#import "ViewController.h"
#import "SMTextStorage.h"
#import "SMAsyncLabel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SMAsyncLabel *label = [[SMAsyncLabel alloc] initWithFrame:CGRectMake(0, 20, 200, 200)];
    NSString *test = @"Hello, World! I know nothing in the world that 😭❤️我们has as一样的 much power as a word. Sometimes I write one, and I look at it, until it begins to shine.🙂😢🙂😢🙂😢哈哈哈哈哈哈weixiasd";
    
    SMTextLayout *layout = [[SMTextLayout alloc] init];
    SMTextStorage *storage = [SMTextStorage sm_textStorageWithText:test frame:CGRectMake(0, 0, 200, 200)];
//    storage.text = test;
    
    label.textArray = @[storage];
    label.layout = layout;
    
    [self.view addSubview:label];

    {
        SMAsyncLabel *label = [[SMAsyncLabel alloc] initWithFrame:CGRectMake(0, 200, 200,  400)];
        NSString *test = @"Hello, World! I know nothing in the world that 😭❤️我们has as一样的 much power as a word. Sometimes I write one, and I look at it, until it begins to shine.🙂😢🙂😢🙂😢哈哈哈哈哈哈weixiasd";
        label.backgroundColor = [UIColor yellowColor];
        SMTextLayout *layout = [[SMTextLayout alloc] init];
        SMTextStorage *storage = [[SMTextStorage alloc] initWithFrame:CGRectMake(0, 200, 200, CGFLOAT_MAX)];
        storage.text = test;
        
        label.textArray = @[storage];
        label.layout = layout;
        
        [self.view addSubview:label];
    }
    
}



@end
