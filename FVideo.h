#import <AudioToolbox/AudioToolbox.h>
#import <Photos/Photos.h>
#import <substrate.h>
#import <UIKit/UIKit.h>

#import "incs/TWRDownloadManager/TWRDownloadManager.h"
#import "incs/JGProgressHUD/JGProgressHUD.h"

@class FBVideoPlayerComponentStatefulView;
@interface FVideo : NSObject

@property (nonatomic, retain) JGProgressHUD *HUD;

+ (id)sharedInstance;
- (void)cleanup;
- (void)handleVideoGesture:(UILongPressGestureRecognizer *)recognizer;
- (void)handleWrapper:(FBVideoPlayerComponentStatefulView *)wrapper;
- (void)startDownload:(NSURL *)url;
- (NSString *)videoPath;
- (UIViewController *)topController;
- (UIView *)topView;
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
- (FBVideoViewManager *)viewManager;
@end