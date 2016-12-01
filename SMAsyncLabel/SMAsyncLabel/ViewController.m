//
//  ViewController.m
//  SMAsyncLabel
//
//  Created by simon on 16/11/24.
//  Copyright © 2016年 simon. All rights reserved.
//

#import "ViewController.h"
#import "SMAsyncLabel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SMAsyncLabel *label = [[SMAsyncLabel alloc] initWithFrame:CGRectMake(0, 20, 200, 400)];
    NSString *test = @"Hello, World! I know nothing in the world that 😭❤️我们has as一样的 much power as a word. Sometimes I write one, and I look at it, until it begins to shine.🙂😢🙂😢🙂😢哈哈哈哈哈哈weixiasd";
    label.font = [UIFont systemFontOfSize:20];
    label.text = test;

    [self.view addSubview:label];

    {
        SMAsyncLabel *label = [[SMAsyncLabel alloc] initWithFrame:CGRectMake(0, 410, 200, 200)];
        NSString *test = @"Hello, World! I know nothing in the world that 😭❤️我们has as一样的 much power as a word. Sometimes I write one, and I look at it, until it begins to shine.🙂😢🙂😢🙂😢哈哈哈哈哈哈weixiasd    sdafasgdhfjg!!!!!!!!!!!!";
        label.backgroundColor = [UIColor yellowColor];
        label.textColor = [UIColor blueColor];
        label.text = test;
        [self.view addSubview:label];
    }
    
}



@end
