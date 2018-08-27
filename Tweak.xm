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

- (void)cleanup { [[NSFileManager defaultManager] removeItemAtPath:[self videoPath] error:NULL]; }

- (void)startDownload:(NSURL *)url {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self cleanup];

    MBFileDownloader *fileDownloader = [[MBFileDownloader alloc] initWithURL:url toFilePath:[self videoPath]];
    [fileDownloader downloadWithSuccess:^{

        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:[self videoPath]]];
        } completionHandler:^(BOOL success, NSError *error) {
            [self cleanup];
            alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Video Saved to Photo Library" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            bgDraw(){
                [alert show];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            });
        }];

    } update:^(float value) {
        bgDraw(){
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        });
    } failure:^(NSError *error) {
        alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        bgDraw(){
            [alert show];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    }];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqual:@"HD"])
        [self startDownload: self.hdURL];
    
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqual:@"SD"])
        [self startDownload: self.sdURL];
}

- (void)handleWrapper:(FBVideoPlayerComponentStatefulView *)wrapper {

	FBVideoViewManager *manager = [wrapper viewManager];
	FBVideoPlaybackController *controller = [manager videoController];
	FBVideoPlaybackItem *item = [controller currentVideoPlaybackItem];

    self.hdURL = [item HDPlaybackURL];
	self.sdURL = [item SDPlaybackURL];

    HBLogInfo(@"hd %@", self.hdURL);
    HBLogInfo(@"sd %@", self.sdURL);

    alert = [[UIAlertView alloc] initWithTitle:@"Choose Video Quality" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    
    if (self.hdURL)
        [alert addButtonWithTitle:@"HD"];
    
    if (self.sdURL)
        [alert addButtonWithTitle:@"SD"];
    
    [alert addButtonWithTitle:@"Dismiss"];

    bgDraw(){
        [alert show];
    });

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
	UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:[FVideo sharedInstance] action:@selector(handleVideoGesture:)];
	gesture.minimumPressDuration = 0.7f;
	gesture.allowableMovement = 50.0f;
	[self addGestureRecognizer:gesture];
}

%end
