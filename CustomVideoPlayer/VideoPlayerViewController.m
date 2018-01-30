//
//  WebinarSelectedViewController.m
//  CustomVideoPlayer
//
//  Created by Arnab on 18/01/18.
//  Copyright © 2018 Arnab Hore. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "AppDelegate.h"

@interface VideoPlayerViewController (){
    IBOutlet UIView *playerContainerView;
    IBOutlet UIView *upcomingWebinrMessageContainerView;
    IBOutlet UILabel *upcomingMessageLabel;
    IBOutlet UIImageView *quoteOftheWeekImage;
    
    IBOutlet UIImageView *headerBg;
    IBOutlet UITableView *table;
    IBOutlet UIView *mainView;
    IBOutlet UIView *clearView;
    IBOutlet UIButton *playPauseButton;
    IBOutlet UILabel *currentTime;
    
    IBOutlet UILabel *presenterNameVideoView;
    IBOutlet UILabel *eventNameNameVideoView;
    
    IBOutlet UILabel *eventName;
    IBOutlet UILabel *presenterName;
    IBOutlet UILabel *eventDetail;
    IBOutlet UIImageView *eventImage;
    
    IBOutlet UILabel *eventTagView;
    IBOutlet NSLayoutConstraint *eventTagViewHeightConstraint;
    IBOutlet UIButton *eventLikeDislike;
    IBOutlet UILabel *eventLikeCount;
    IBOutlet UIButton *eventWatchListButton;
    IBOutlet UIButton *eventDownloadButton;
    IBOutlet UIButton *eventPodcastButton;
    IBOutlet NSLayoutConstraint *eventWatchListButtonConstraint;
    IBOutlet NSLayoutConstraint *eventDownloadButtonConstraint;
    
    IBOutlet UILabel *moreFromPresenterLabel;

    IBOutlet UIButton *nextButton;
    IBOutlet UIButton *previousButton;
    
    AVPlayerViewController *playerViewController;
    IBOutlet UISlider *progressBar;
    IBOutlet UIView *playerLabelView;
    IBOutlet UIButton *muteButton;
    int tapCount;
    AVPlayer *player;
    UIImage *playButtonImage;
    UIImage *pauseButtonImage;
    UIButton *button;
    UIView *contentView;
    NSMutableArray *webinarsOfPresenter;
    NSInteger selectedIndex;
    
    IBOutlet UILabel *eventstatus;
    IBOutlet UIProgressView *eventProgress;
    NSURLSessionDownloadTask *eventDownloadTask;
    
    NSMutableDictionary *backgroundDownloadDict;
    NSMutableDictionary *indexPathAndTaskDict;
    NSArray *videoNames;
    int videoCounter;
}

@end

@implementation VideoPlayerViewController
@synthesize buttons;

#pragma mark - IBAction -
- (IBAction)previousButton:(UIButton *)sender {
    if (videoCounter-1 > 0) {
        videoCounter--;
    } else {
        videoCounter = (int)videoNames.count - 1;
    }
    [self playNextPrevious];
}
- (IBAction)nextButton:(UIButton *)sender {
    if (videoCounter+1 < videoNames.count) {
        videoCounter++;
    } else {
        videoCounter = 0;
    }
    [self playNextPrevious];
}

-(IBAction)progressBarValueChanged:(id)sender{
    [player pause];
    float progressBarValue = progressBar.value;
    CMTime playerDuration = player.currentItem.asset.duration;
    double duration = CMTimeGetSeconds(playerDuration);
    CMTime newTime = CMTimeMakeWithSeconds(progressBarValue * duration, player.currentTime.timescale);
    [player seekToTime:newTime];
    [player play];
}

-(IBAction)playPause:(id)sender{
    NSLog(@"%f",player.rate);
    if (player.rate == 0) {
        [player play];
        [playPauseButton setBackgroundImage:pauseButtonImage forState:UIControlStateNormal];
    } else if (player.rate == 1){
        [player pause];
        [playPauseButton setBackgroundImage:playButtonImage forState:UIControlStateNormal];
    }
}
-(IBAction)setVolumeUp:(id)sender{
    NSLog(@"pv1 %f",player.volume);
    if (player.volume < 1.0) {
        player.volume = player.volume + 0.1;
    }
    NSLog(@"pv2 %f",player.volume);
    [self showVolume];
}
-(IBAction)setVolumeDown:(id)sender{
    NSLog(@"pv1 %f",player.volume);
    if (player.volume > 0.0) {
        player.volume = player.volume - 0.1;
    }
    NSLog(@"pv2 %f",player.volume);
    [self showVolume];
}
-(IBAction)mute:(id)sender{
    if (player.isMuted) {
        player.muted = NO;
        [self showVolume];
        UIImage *muteButtonImage = [UIImage imageNamed:@"ic_sound_plus.png"];
        [muteButton setImage:muteButtonImage forState:UIControlStateNormal];
    } else {
        player.muted = YES;
        UIImage *muteButtonImage = [UIImage imageNamed:@"ic_sound_mute.png"];
        [muteButton setImage:muteButtonImage forState:UIControlStateNormal];
    }
}
#pragma mark - End -

#pragma mark - ViewLifeCycle -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    eventImage.layer.cornerRadius = eventImage.frame.size.width/2;
    eventImage.clipsToBounds = YES;
    webinarsOfPresenter = [[NSMutableArray alloc]init];
    progressBar.value = 0.0;
    //customize progressBar
    [progressBar setMinimumTrackTintColor:[UIColor colorWithRed:(126/255.0) green:(200/255.0) blue:(222/255.0) alpha:1]];
    [progressBar setMaximumTrackTintColor:[UIColor colorWithRed:(209/255.0) green:(209/255.0) blue:(209/255.0) alpha:1]];
    UIImage *thumbImage = [UIImage imageNamed:@"vol_cir.png"];
    [progressBar setThumbImage:thumbImage forState:UIControlStateNormal];
    
    //hide/show play/pause button
    playButtonImage = [UIImage imageNamed:@"play_button.png"];
    pauseButtonImage = [UIImage imageNamed:@"pause_button.png"];
    playPauseButton.hidden = true;
    playerLabelView.hidden = true;
    [playPauseButton setBackgroundImage:pauseButtonImage forState:UIControlStateNormal];
    
    // Delay execution of for 5 seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        NSLog(@"tc %d",tapCount);
        if (tapCount == 0) {
            playPauseButton.hidden = true;
            playerLabelView.hidden = true;
        }
    });
    
    videoNames = @[@"big_buck_bunny", @"big_buck_bunny"];
    videoCounter = 0;
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:true];
    
    NSString *videoName = [videoNames objectAtIndex:videoCounter];
    NSString *fullpath = [[NSBundle mainBundle] pathForResource:videoName ofType:@"mp4"];
    NSURL* vedioURL =[NSURL fileURLWithPath:fullpath];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:vedioURL];
    player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.player = player;
    playerViewController.showsPlaybackControls = false;
    playerViewController.view.frame = mainView.bounds;
    [mainView addSubview:playerViewController.view];
    [player play];
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    [clearView addGestureRecognizer:singleTapGestureRecognizer];
    
    double interval = .1f;
    
    CMTime playerDuration = player.currentItem.duration; // return player duration.
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        CGFloat width = CGRectGetWidth([progressBar bounds]);
        interval = 0.5f * duration / width;
    }
    __weak typeof(self) weakSelf = self;
    /* Update the scrubber during normal playback. */
    if (interval > 0) {
        [player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                             queue:NULL
                                        usingBlock:
         ^(CMTime time)
         {
             [weakSelf syncScrubber];
         }];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    if (player.rate == 1){
        [player pause];
        [playPauseButton setBackgroundImage:playButtonImage forState:UIControlStateNormal];
    }
}

#pragma mark - End -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods -
- (void)syncScrubber
{
    CMTime playerDuration = player.currentItem.asset.duration;
    if (CMTIME_IS_INVALID(playerDuration))
    {
        progressBar.minimumValue = 0.0;
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration) && (duration > 0))
    {
        float minValue = [ progressBar minimumValue];
        float maxValue = [ progressBar maximumValue];
        double time = CMTimeGetSeconds([player currentTime]);
        [progressBar setValue:(maxValue - minValue) * time / duration + minValue];
    }
    
    //time label
    NSUInteger playerTime = CMTimeGetSeconds(player.currentTime);
    NSUInteger dMinutes = floor(playerTime / 60);
    NSUInteger dSeconds = floor(playerTime % 3600 % 60);
    
    NSString *videoDurationText = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)dMinutes, (unsigned long)dSeconds];
    currentTime.text = videoDurationText;
    
    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[player currentItem]];
    
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero completionHandler:nil];
}

-(void)handleSingleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer{
    NSLog(@"tap");
    if (playPauseButton.isHidden) {
        playPauseButton.hidden = false;
        playerLabelView.hidden = false;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            playPauseButton.hidden = true;
            playerLabelView.hidden = true;
        });
    } else if (!playPauseButton.isHidden){
        playPauseButton.hidden = true;
        playerLabelView.hidden = true;
    }
    tapCount++;
}

-(void)showVolume{
    NSLog(@"pv3 %f",player.volume);
    int playerVolume = roundf(player.volume * 10);
    NSLog(@"PV %d",playerVolume);
    for (UIButton *b in self.buttons) {
        if (b.tag > 0 && b.tag<= playerVolume) {
            UIImage *buttonImage = [UIImage imageNamed:@"vol_incr.png"];
            [b setBackgroundImage:buttonImage forState:UIControlStateNormal];
        } else if (b.tag > playerVolume){
            UIImage *buttonImage = [UIImage imageNamed:@"vol_dcr.png"];
            [b setBackgroundImage:buttonImage forState:UIControlStateNormal];
        }
    }
}

-(void) playNextPrevious {
    NSString *videoName = [videoNames objectAtIndex:videoCounter];
    NSString *fullpath = [[NSBundle mainBundle] pathForResource:videoName ofType:@"mp4"];
    NSURL* vedioURL =[NSURL fileURLWithPath:fullpath];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:vedioURL];
    
    [player replaceCurrentItemWithPlayerItem:playerItem];
}
#pragma mark - End -

@end

