//
//  ViewController.m
//  OrientationTesting
//
//  Created by Hamilton Chapman on 19/04/2018.
//  Copyright © 2018 hc.gg. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSImage *test = [NSImage imageNamed:@"test.jpg"];

    NSLog(@"START ORIENTATION: %ld", test.imageOrientation);

    int orientation = 2;
    NSImage *mutatedTest = [NSImage setImageOrientation:test withOrientation:orientation];

    NSLog(@"FINAL ORIENTATION: %ld", mutatedTest.imageOrientation);
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

@end
