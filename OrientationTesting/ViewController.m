//
//  ViewController.m
//  OrientationTesting
//
//  Created by Hamilton Chapman on 19/04/2018.
//  Copyright © 2018 hc.gg. All rights reserved.
//

#import "ViewController.h"

NSImage * (^setImageOrientation)() = ^(NSImage *sourceImage, int orientation) {
    NSData *tiffData = [sourceImage TIFFRepresentation];
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)tiffData, NULL);

    CFMutableDictionaryRef imageProperties = CFDictionaryCreateMutableCopy(NULL, 0, CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL));
    NSLog(@"BEFORE PROPERTY MUTATING %@", imageProperties);

    CFNumberRef orientationNum = (__bridge CFNumberRef)[[NSNumber alloc] initWithInt:orientation];
    CFDictionarySetValue(imageProperties, kCGImagePropertyOrientation, orientationNum);

    NSMutableDictionary *tiffPropDict = [[NSMutableDictionary alloc] init];
    [tiffPropDict setObject:[[NSNumber alloc] initWithInt:orientation] forKey:(NSString *)kCGImagePropertyTIFFOrientation];
    CFDictionarySetValue(imageProperties, kCGImagePropertyTIFFDictionary, (__bridge const void *)(tiffPropDict));

    NSMutableData *newImageData = [[NSMutableData alloc] init];
    CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData((CFMutableDataRef)newImageData, CGImageSourceGetType(imageSource), 1, NULL);
    CGImageDestinationAddImageFromSource(imageDestination, imageSource, 0, imageProperties);
    CGImageDestinationFinalize(imageDestination);

    NSDictionary *backAgain = (__bridge NSDictionary*)imageProperties;
    NSLog(@"AFTER PROPERTY MUTATING %@", backAgain);

    NSImage *img = [[NSImage alloc] initWithData:newImageData];
    return img;
};

NSInteger (^getImageOrientation)() = ^(NSImage *sourceImage) {
    NSData *tiffData = [sourceImage TIFFRepresentation];
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)tiffData, NULL);

    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:NO], (NSString *)kCGImageSourceShouldCache,
                             nil];
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (CFDictionaryRef)options);

    if (imageProperties) {
        NSInteger orientationValue = 1;
        CFTypeRef val = CFDictionaryGetValue(imageProperties, kCGImagePropertyOrientation);

        if (val) {
            CFNumberGetValue(val, kCFNumberNSIntegerType, &orientationValue);
        } else {
            NSLog(@"Error getting orientation value");
        }

        CFRelease(imageProperties);
        CFRelease(imageSource);

        return orientationValue;
    } else {
        CFRelease(imageSource);
        return (long)-1;
    }
};

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSImage *test = [NSImage imageNamed:@"test.jpg"];

    NSLog(@"START ORIENTATION: %ld", (long)getImageOrientation(test));

    int orientation = 5;
    NSImage *mutatedTest = setImageOrientation(test, orientation);

    NSLog(@"FINAL ORIENTATION: %ld", (long)getImageOrientation(mutatedTest));

    // DEBUG
    CGImageRef cgRef = [mutatedTest CGImageForProposedRect:NULL context:nil hints:nil];
    NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithCGImage:cgRef];
    NSData *data = [newRep representationUsingType:NSJPEGFileType properties:@{}];
    [data writeToFile: [[[@"/Users/hami/Desktop/" stringByAppendingString:[@(orientation) stringValue]] stringByAppendingString: @"mutatedTest"] stringByAppendingString:@".jpg"] atomically: NO];
    // DEBUG
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

@end
