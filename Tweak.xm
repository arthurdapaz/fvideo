#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <substrate.h>

#import "FVideo.h"


@implementation FVideo

+ (id)sharedInstance {
	static FVideo *__sharedInstance;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		__sharedInstance = [[self alloc] init];
	});  

	return __sharedInstance;
}

- (NSString *)videoPath {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *cachesDirectory = [paths objectAtIndex:0];
  return [cachesDirectory stringByAppendingPathComponent:@"tempvideo.mp4"];
}

- (void)cleanup {
  [[NSFileManager defaultManager] removeItemAtPath:[self videoPath] error:NULL];
}

- (void)startDownload:(NSURL *)url {

    [self cleanup];

    self.HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    self.HUD.textLabel.textAlignment = NSTextAlignmentCenter;
    self.HUD.textLabel.text = @"Downloading";
    [self.HUD showInView:[self topView]];

    [[TWRDownloadManager sharedManager]
        downloadFileForURL:[url absoluteString]
        withName:@"tempvideo.mp4"
        inDirectoryNamed:nil
        progressBlock:^(CGFloat progress)
        {
          self.HUD.textLabel.text = [NSString stringWithFormat:@"%.0f%%", progress * 100];
        }
        completionBlock:^(BOOL completed)
        {
            self.HUD.textLabel.text = @"Saving...";

            NSURL *theVideoFile = [NSURL fileURLWithPath:[self videoPath]];

            /*UIDocumentInteractionController *docCtrl = [UIDocumentInteractionController interactionControllerWithURL:theVideoFile];
            [docCtrl presentOpenInMenuFromRect:CGRectZero inView:[self topView] animated:YES];*/


            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:theVideoFile];
                NSLog(@"FVideo: %@", changeRequest.description);
            } completionHandler:^(BOOL success, NSError *error) {
                [self.HUD dismissAnimated:NO];
                if (success) {
                    self.HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
                    self.HUD.textLabel.text = @"Saved!";
                    self.HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
                    self.HUD.animation = [JGProgressHUDFadeZoomAnimation animation];
                    [self.HUD showInView:[self topView]];
                    [self.HUD dismissAfterDelay:2];
                    [self cleanup];
                } else {
                    self.HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
                    self.HUD.textLabel.text = @"Error :(";
                    self.HUD.indicatorView = [[JGProgressHUDErrorIndicatorView alloc] init];
                    [self.HUD showInView:[self topView]];
                    [self.HUD dismissAfterDelay:2];
                    // NSLog(@"AVISO: something wrong %@", error.localizedDescription);
                    [self cleanup];
                }
            }];



        } enableBackgroundMode:YES];

}

- (UIViewController *)topController {
    UIViewController *rootController = [UIApplication sharedApplication].keyWindow.rootViewController;

    while (rootController.presentedViewController) {
        rootController = rootController.presentedViewController;
    }
    return rootController;
}

- (UIView *)topView {
    UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    return rootView;
}

- (void)handleWrapper:(FBVideoPlayerComponentStatefulView *)wrapper {

	FBVideoViewManager *manager = [wrapper viewManager];
	FBVideoPlaybackController *controller = [manager videoController];
	FBVideoPlaybackItem *item = [controller currentVideoPlaybackItem];

	NSURL *hdURL = [item HDPlaybackURL];
	NSURL *sdURL = [item SDPlaybackURL];


UIAlertController * view=   [UIAlertController
                                 alertControllerWithTitle:@"Choose video quality"
                                 message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
   UIAlertAction* hd = [UIAlertAction
                        actionWithTitle:@"HD"
                        style:UIAlertActionStyleDefault
                        handler:^(UIAlertAction * action)
                        {
                            [self startDownload:hdURL];
                            [view dismissViewControllerAnimated:YES completion:nil];
                             
                        }];
    
  UIAlertAction* sd = [UIAlertAction
                            actionWithTitle:@"SD"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                [self startDownload:sdURL];
                                [view dismissViewControllerAnimated:YES completion:nil];
                            }];

	if (hdURL) [view addAction:hd];

   [view addAction:sd];

   [[self topController] presentViewController:view animated:YES completion:nil];
   AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

}

- (void)handleVideoGesture:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
    	[self handleWrapper:(FBVideoPlayerComponentStatefulView *)[recognizer view]];
    }
}

@end

%hook FBVideoPlayerComponentStatefulView

- (void)addVideoContainerViewFromViewManager {
	%orig;

	UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:[FVideo sharedInstance]
																						  action:@selector(handleVideoGesture:)];
	gesture.minimumPressDuration = 0.7f;
	gesture.allowableMovement = 50.0f;
	[self addGestureRecognizer:gesture];

}

%end
