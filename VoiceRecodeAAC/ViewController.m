//
//  ViewController.m
//  VoiceRecodeAAC
//
//  Created by Teddy Lin on 10/30/15.
//  Copyright © 2015 Zhimei Inc. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate> {
    
    BOOL recording;
    BOOL playing;
}

@property (strong, nonatomic) NSURL *soundFileURL;
@property (strong, nonatomic) AVAudioRecorder *soundRecorder;
@property (strong, nonatomic) AVAudioPlayer *player;

@property (weak, nonatomic) IBOutlet UIButton *recordOrStopButton;
@property (weak, nonatomic) IBOutlet UIButton *playOrStopButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *tempDir = NSTemporaryDirectory ();
    NSString *soundFilePath =
    [tempDir stringByAppendingString: @"sound.aac"];
    
    NSURL *newURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    self.soundFileURL = newURL;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    audioSession.delegate = self; 这个代理已经废除了
    [audioSession setActive: YES error: nil];
    
    
    recording = NO;
    playing = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) recordOrStop: (id) sender {
    
    if (recording) {
        
        NSTimeInterval duration = [self.soundRecorder currentTime];
        
        [self.soundRecorder stop];
        recording = NO;
        
        [self.recordOrStopButton setTitle: @"Record" forState:
         UIControlStateNormal];
        [self.recordOrStopButton setTitle: @"Record" forState:
         UIControlStateHighlighted];
        [[AVAudioSession sharedInstance] setActive: NO error: nil];
        
        // 获取文件的大小
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;
        NSDictionary *attr = [fm attributesOfItemAtPath:[self.soundFileURL path] error:&error];
        
        CGFloat size = [[attr objectForKey:NSFileSize] unsignedLongLongValue] / 1024.0;
//        NSLog(@"File attribute: %@, error: %@", attr, error);
        NSLog(@"duration: %f, size: %f KB，KB/s: %f", duration, size, size/duration);
        
        
    } else {
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        [[AVAudioSession sharedInstance]
         setCategory: AVAudioSessionCategoryRecord
         error: nil];
        
        
        // 采样率8k，，录制的音频大约在 2k/s
//        NSDictionary *recordSettings =
//        [[NSDictionary alloc] initWithObjectsAndKeys:
//         [NSNumber numberWithFloat: 8000.0], AVSampleRateKey,
//         [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
//         [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
//         [NSNumber numberWithInt: 8], AVLinearPCMBitDepthKey,
//         [NSNumber numberWithInt: AVAudioQualityMin],
//         AVEncoderAudioQualityKey,
//         nil];
        
        // 采样率16k, 3k/s
//        NSDictionary *recordSettings =
//        [[NSDictionary alloc] initWithObjectsAndKeys:
//         [NSNumber numberWithFloat: 16000.0], AVSampleRateKey,
//         [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
//         [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
//         [NSNumber numberWithInt: 8], AVLinearPCMBitDepthKey,
//         [NSNumber numberWithInt: AVAudioQualityMin],
//         AVEncoderAudioQualityKey,
//         nil];
        
        NSDictionary *recordSettings =
        [[NSDictionary alloc] initWithObjectsAndKeys:
         [NSNumber numberWithFloat: 16000.0], AVSampleRateKey,
         [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
         [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
         [NSNumber numberWithInt: 8], AVLinearPCMBitDepthKey,
         [NSNumber numberWithInt: AVAudioQualityMin],
         AVEncoderAudioQualityKey,
         nil];


        NSError *error = nil;
        AVAudioRecorder *newRecorder =
        [[AVAudioRecorder alloc] initWithURL: self.soundFileURL
                                    settings: recordSettings
                                       error: &error];
        
        
        self.soundRecorder = newRecorder;
        
        self.soundRecorder.delegate = self;
        [self.soundRecorder prepareToRecord];
        [self.soundRecorder record];
        [self.recordOrStopButton setTitle: @"Stop" forState: UIControlStateNormal];
        [self.recordOrStopButton setTitle: @"Stop" forState: UIControlStateHighlighted];
        
//        NSLog(@"recorder error: %@", error);
        recording = YES;
    }
}

- (IBAction)playOrStop:(id)sender {
    if (playing) {
        [self.player stop];
        playing = NO;
        
        [self.playOrStopButton setTitle: @"Play" forState: UIControlStateNormal];
        [self.playOrStopButton setTitle: @"Play" forState: UIControlStateHighlighted];
    }
    else {
        NSError *setCategoryErr = nil;
        NSError *activationErr  = nil;
        
        [[AVAudioSession sharedInstance]
         setActive: YES
         error: &activationErr];
        [[AVAudioSession sharedInstance]
         setCategory: AVAudioSessionCategoryPlayback
         error: &setCategoryErr];
        
        
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.soundFileURL error:nil];
        self.player.delegate = self;
        [self.player prepareToPlay];
        [self.player play];
        
        [self.playOrStopButton setTitle: @"Stop" forState: UIControlStateNormal];
        [self.playOrStopButton setTitle: @"Stop" forState: UIControlStateHighlighted];
        
        playing = YES;

    }
    
    
}


#pragma mark - AVAudioPlayer delegates

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    playing = NO;
    
    [self.playOrStopButton setTitle: @"Play" forState: UIControlStateNormal];
    [self.playOrStopButton setTitle: @"Play" forState: UIControlStateHighlighted];
}

@end
