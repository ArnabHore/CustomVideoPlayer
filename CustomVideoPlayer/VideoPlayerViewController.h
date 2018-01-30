//
//  WebinarSelectedViewController.h
//  CustomVideoPlayer
//
//  Created by Arnab on 18/01/18.
//  Copyright © 2018 Arnab Hore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>


@interface VideoPlayerViewController : UIViewController
@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray* buttons;
@end
