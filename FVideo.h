#import <AudioToolbox/AudioToolbox.h>
#import <Photos/Photos.h>
#import <substrate.h>
#import <UIKit/UIKit.h>

#import "incs/MBFileDownloader/MBFileDownloader.h"

#define bgRun(void) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
#define bgDraw(void) dispatch_async(dispatch_get_main_queue(), ^(void)


@class FBVideoPlayerComponentStatefulView;

@interface FVideo : NSObject {
    UIAlertView *alert;
}
@property (nonatomic, retain) NSURL *sdURL;
@property (nonatomic, retain) NSURL *hdURL;

+ (id)sharedInstance;
- (void)cleanup;
- (void)handleVideoGesture:(UILongPressGestureRecognizer *)recognizer;
- (void)handleWrapper:(FBVideoPlayerComponentStatefulView *)wrapper;
- (void)startDownload:(NSURL *)url;
- (NSString *)videoPath;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@interface FBVideoPlaybackItem
- (NSURL *)SDPlaybackURL;
- (NSURL *)HDPlaybackURL;
@end

@interface FBVideoPlaybackController
- (FBVideoPlaybackItem *)currentVideoPlaybackItem;
@end

@interface FBVideoViewManager : NSObject
- (FBVideoPlaybackController *)videoController;
@end

@interface FBVideoPlayerComponentStatefulView : UIView
{
    FBVideoViewManager *_viewManager;
}
@property(retain, nonatomic) FBVideoViewManager *viewManager;
@end
