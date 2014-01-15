//
//  ViewController.m
//  TestSpeed1
//
//  Created by Mark Jones on 1/14/14.
//  Copyright (c) 2014 Mark Jones. All rights reserved.
//

#import "ViewController.h"

#import "MyCustomCollectionView.h"

@interface ViewController () <NSURLSessionDownloadDelegate>
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *images;

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation ViewController

- (NSURLSession *)session
{
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return _session;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.images = @[@"http://prod.images.seahawks.clubs.nflcdn.com/image-web/NFL/CDA/data/deployed/prod/SEAHAWKS/assets/images/imported/SEA/photos/clubimages/2014/01-January/temp_MAU0398-7--nfl_mezz_1280_1024.jpg",@"http://www.seahawks.com/videos-photos/photo-gallery/Photo-Gallery---Seahawks-vs-Saints-12th-Man/883df7a9-5367-45fb-974d-70eec7bf85d6#e1540696-1773-427b-ae63-faf516efe653",@"http://prod.images.seahawks.clubs.nflcdn.com/image-web/NFL/CDA/data/deployed/prod/SEAHAWKS/assets/images/imported/SEA/photos/clubimages/2014/01-January/tempIMG_0939--nfl_mezz_1280_1024.jpg",@"http://prod.images.seahawks.clubs.nflcdn.com/image-web/NFL/CDA/data/deployed/prod/SEAHAWKS/assets/images/imported/SEA/photos/clubimages/2014/01-January/tempIMG_0664-2--nfl_mezz_1280_1024.jpg",@"http://prod.images.seahawks.clubs.nflcdn.com/image-web/NFL/CDA/data/deployed/prod/SEAHAWKS/assets/images/imported/SEA/photos/clubimages/2014/01-January/tempIMG_0612--nfl_mezz_1280_1024.jpg",@"http://prod.images.seahawks.clubs.nflcdn.com/image-web/NFL/CDA/data/deployed/prod/SEAHAWKS/assets/images/imported/SEA/photos/clubimages/2014/01-January/tempIMG_0332--nfl_mezz_1280_1024.jpg",@"http://prod.images.seahawks.clubs.nflcdn.com/image-web/NFL/CDA/data/deployed/prod/SEAHAWKS/assets/images/imported/SEA/photos/clubimages/2014/01-January/tempIMG_0176--nfl_mezz_1280_1024.jpg"];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 7;
}


- (NSURL *)urlForIndex:(NSInteger)index
{
    NSURL *url = [NSURL URLWithString:self.images[index]];
    return url;
}

- (NSURL *)localPathForIndex:(NSInteger)index
{
    NSString *docsDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *targetPath = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"image%d.jpg",index]];
    return [NSURL fileURLWithPath:targetPath];
}

- (BOOL)fileExists:(NSURL *)fileURL
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MyCustomCollectionView *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"MyCustomCell" forIndexPath:indexPath];
    
    if (!cell.imageView.image) {
        
        [cell.activityIndicator startAnimating];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            NSURL *url = [self urlForIndex:indexPath.row];
            NSURL *toURL = [self localPathForIndex:indexPath.row];
            
            if (![self fileExists:toURL])
            {
                NSURLSessionDownloadTask *downloadImageTask = [self.session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                    
                    NSError *fileError = nil;
                    
                    if([[NSFileManager defaultManager] copyItemAtURL:location toURL:toURL error:&fileError])
                    {
                        NSLog(@"copied image file to %@",toURL);
                    }
                    else
                    {
                        NSLog(@"error copying file to local path %@",fileError);
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //update cell with image
                        NSLog(@"image path is %@",[toURL path]);
                        cell.imageView.image = [UIImage imageWithContentsOfFile:[toURL path]];
                        
                        [cell.activityIndicator stopAnimating];
                    });
                    
                }];
                
                [downloadImageTask resume];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //update cell with image
                    NSLog(@"image path is %@",[toURL path]);
                    cell.imageView.image = [UIImage imageWithContentsOfFile:[toURL path]];
                    
                    [cell.activityIndicator stopAnimating];
                });
            }
        });
    }
    
    return cell;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"Error downloading...");
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

@end
