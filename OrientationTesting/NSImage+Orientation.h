//
//  NSImage+Orientation.h
//  OrientationTesting
//
//  Created by Hamilton Chapman on 20/04/2018.
//  Copyright © 2018 hc.gg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface NSImage (Orientation)
- (NSInteger)imageOrientation;
+ (NSImage *)setImageOrientation:(NSImage *)sourceImage withOrientation:(int)orientation;
@end
