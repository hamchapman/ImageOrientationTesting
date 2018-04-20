//
//  NSImage+Orientation.m
//  OrientationTesting
//
//  Created by Hamilton Chapman on 20/04/2018.
//  Copyright © 2018 hc.gg. All rights reserved.
//

#import "NSImage+Orientation.h"

@implementation NSImage (Orientation)

- (NSInteger)imageOrientation {
    NSData *tiffData = [self TIFFRepresentation];
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)tiffData, NULL);

    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:NO], (NSString *)kCGImageSourceShouldCache,
                             nil];
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (CFDictionaryRef)options);

    if (imageProperties) {
        NSInteger orientationValue = 0;
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
}

+ (NSImage *)setImageOrientation:(NSImage *)sourceImage withOrientation:(int)orientation {
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

    // DEBUG
    CGImageRef cgRef = [img CGImageForProposedRect:NULL context:nil hints:nil];
    NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithCGImage:cgRef];
    NSData *data = [newRep representationUsingType:NSJPEGFileType properties:@{}];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES );
    NSString* desktopPath = [paths objectAtIndex:0];
    NSString *fileName = [@"mutatedtest" stringByAppendingString:[@(orientation) stringValue]];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.jpg", desktopPath, fileName];

    NSError *error;
    BOOL success = [data writeToFile:filePath options:0 error:&error];
    if (!success) {
        NSLog(@"writeToFile failed with error %@", error);
    }
    // DEBUG

    return img;
}


@end
