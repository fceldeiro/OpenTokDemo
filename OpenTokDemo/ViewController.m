

#import "ViewController.h"
#import <OpenTok/OpenTok.h>

@interface ViewController ()
<OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate>
@property (weak, nonatomic) IBOutlet UIView *myCameraView;
@property (weak, nonatomic) IBOutlet UIView *counterPartView;

@property (nonatomic,strong) NSMutableArray * subscribers;

@end

@implementation ViewController {
    OTSession* _session;
    OTPublisher* _publisher;
//    OTSubscriber* _subscriber;
}

- (IBAction)onBtnMutePressed:(id)sender {
   
     _publisher.publishAudio = !_publisher.publishAudio;

}
- (IBAction)onBtnCameraOnOffPressed:(id)sender {
    _publisher.publishVideo = !_publisher.publishVideo;
}
- (IBAction)onSwitchCameraPressed:(id)sender {
    _publisher.cameraPosition = _publisher.cameraPosition == AVCaptureDevicePositionFront ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
}
- (IBAction)onBtnHangUpPressed:(id)sender {
    


    OTError * error = nil;
    if (_publisher.session){
            [_session unpublish:_publisher error:&error];
    }
    else{

        [self doPublish];
//        [_session publish:_publisher error:&error];
        
    }

    
    NSLog(@"Error %@",error);
    
}


// *** Fill the following variables using your own Project info  ***
// ***          https://dashboard.tokbox.com/projects            ***
// Replace with your OpenTok API key
static NSString* const kApiKey = @"45191042";
// Replace with your generated session ID
static NSString* const kSessionId = @"1_MX40NTE5MTA0Mn5-MTQyNzMxNTQ1MTUyN345WnlzTVdYaEJJSkpkRkw3WGVrM0lGMTV-fg";
// Replace with your generated token




// Change to NO to subscribe to streams other than your own.
static bool subscribeToSelf = NO;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Step 1: As the view comes into the foreground, initialize a new instance
    // of OTSession and begin the connection process.
    
    
    
    _session = [[OTSession alloc] initWithApiKey:kApiKey
                                       sessionId:kSessionId
                                        delegate:self];
    [self doConnect];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (UIUserInterfaceIdiomPhone == [[UIDevice currentDevice]
                                      userInterfaceIdiom])
    {
        return NO;
    } else {
        return YES;
    }
}
#pragma mark - OpenTok methods

/**
 * Asynchronously begins the session connect process. Some time later, we will
 * expect a delegate method to call us back with the results of this action.
 */
- (void)doConnect
{
    OTError *error = nil;
    
    [_session connectWithToken:self.userToken error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
}

/**
 * Sets up an instance of OTPublisher to use with this session. OTPubilsher
 * binds to the device camera and microphone, and will provide A/V streams
 * to the OpenTok session.
 */
- (void)doPublish
{
    _publisher =
    [[OTPublisher alloc] initWithDelegate:self
                                     name:[[UIDevice currentDevice] name]];
    
    OTError *error = nil;
    [_session publish:_publisher error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
    
    [self.view addSubview:_publisher.view];
    [self.myCameraView addSubview:_publisher.view];
    
    
    [_publisher.view setFrame:CGRectMake(0, 0, self.myCameraView.frame.size.width, self.myCameraView.frame.size.height)];
}

/**
 * Cleans up the publisher and its view. At this point, the publisher should not
 * be attached to the session any more.
 */
- (void)cleanupPublisher {
    [_publisher.view removeFromSuperview];
    _publisher = nil;
    // this is a good place to notify the end-user that publishing has stopped.
}

/**
 * Instantiates a subscriber for the given stream and asynchronously begins the
 * process to begin receiving A/V content for this stream. Unlike doPublish,
 * this method does not add the subscriber to the view hierarchy. Instead, we
 * add the subscriber only after it has connected and begins receiving data.
 */
- (void)doSubscribe:(OTStream*)stream
{
    if (!self.subscribers){
        self.subscribers = [NSMutableArray arrayWithCapacity:3];
        
    }
    OTSubscriber * _subscriber;
    
    _subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
    
    [self.subscribers addObject:_subscriber];
    
    OTError *error = nil;
    [_session subscribe:_subscriber error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
}

-(void) layoutSubscribers{
    
    
    CGFloat subscriberHeight = self.counterPartView.frame.size.height / self.subscribers.count;
    for (int i = 0 ; i<self.subscribers.count ; i++){
        OTSubscriber * otSubscriber = self.subscribers[i];
        [otSubscriber.view setFrame:CGRectMake(0, subscriberHeight*i, self.counterPartView.frame.size.width, subscriberHeight)];
        
        
        [self.counterPartView addSubview:otSubscriber.view];
        
        
        
    }

}
/**
 * Cleans the subscriber from the view hierarchy, if any.
 * NB: You do *not* have to call unsubscribe in your controller in response to
 * a streamDestroyed event. Any subscribers (or the publisher) for a stream will
 * be automatically removed from the session during cleanup of the stream.
 */
- (void)cleanupSubscriber:(OTSubscriber*) subscriber
{
  //  [_subscriber.view removeFromSuperview];
  //  _subscriber = nil;
    [subscriber.view removeFromSuperview];
    [self.subscribers removeObject:subscriber];
    [self layoutSubscribers];
}

# pragma mark - OTSession delegate callbacks

- (void)sessionDidConnect:(OTSession*)session
{
    NSLog(@"sessionDidConnect (%@)", session.sessionId);
    
    // Step 2: We have successfully connected, now instantiate a publisher and
    // begin pushing A/V streams into OpenTok.
    [self doPublish];
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    NSString* alertMessage =
    [NSString stringWithFormat:@"Session disconnected: (%@)",
     session.sessionId];
    NSLog(@"sessionDidDisconnect (%@)", alertMessage);
}


- (void)session:(OTSession*)mySession
  streamCreated:(OTStream *)stream
{
    NSLog(@"session streamCreated (%@)", stream.streamId);
    
    // Step 3a: (if NO == subscribeToSelf): Begin subscribing to a stream we
    // have seen on the OpenTok session.
    
    
    //if (nil == _subscriber && !subscribeToSelf)
   // {
        [self doSubscribe:stream];
   // }
    
}

- (void)session:(OTSession*)session
streamDestroyed:(OTStream *)stream
{
    
    NSLog(@"session streamDestroyed (%@)", stream.streamId);
    
    OTSubscriber *subscriberToRemove = nil;
    for (OTSubscriber * subscriber in self.subscribers){

    
        if ([subscriber.stream.streamId isEqualToString:stream.streamId])
        {
            subscriberToRemove = subscriber;
            break;

        }
}
    if (subscriberToRemove){
                [self cleanupSubscriber:subscriberToRemove];
    }
}

- (void)  session:(OTSession *)session
connectionCreated:(OTConnection *)connection
{
    NSLog(@"session connectionCreated (%@)", connection.connectionId);
}

- (void)    session:(OTSession *)session
connectionDestroyed:(OTConnection *)connection
{
    NSLog(@"session connectionDestroyed (%@)", connection.connectionId);
    
    OTSubscriber *subscriberToRemove = nil;
    for (OTSubscriber * subscriber in self.subscribers){
        
        
        if ([subscriber.stream.connection.connectionId isEqualToString:connection.connectionId])
        {
            subscriberToRemove = subscriber;
            break;
            
        }
    }
    if (subscriberToRemove){
        [self cleanupSubscriber:subscriberToRemove];
    }

    
//    if ([_subscriber.stream.connection.connectionId
//         isEqualToString:connection.connectionId])
//    {
//        [self cleanupSubscriber];
//    }
}

- (void) session:(OTSession*)session
didFailWithError:(OTError*)error
{
    NSLog(@"didFailWithError: (%@)", error);
}

# pragma mark - OTSubscriber delegate callbacks

- (void)subscriberDidConnectToStream:(OTSubscriberKit*)subscriber
{
    NSLog(@"subscriberDidConnectToStream (%@)",
          subscriber.stream.connection.connectionId);
    //assert(_subscriber == subscriber);
  
    [self layoutSubscribers];
    //    [_subscriber.view setFrame:CGRectMake(0, 0  , self.counterPartView.frame.size.width,
    //                                      self.counterPartView.frame.size.height)];
    
  //  [self.counterPartView addSubview:_subscriber.view];
    //    [self.view addSubview:_subscriber.view];
}

- (void)subscriber:(OTSubscriberKit*)subscriber
  didFailWithError:(OTError*)error
{
    NSLog(@"subscriber %@ didFailWithError %@",
          subscriber.stream.streamId,
          error);
}

# pragma mark - OTPublisher delegate callbacks

- (void)publisher:(OTPublisherKit *)publisher
    streamCreated:(OTStream *)stream
{
    // Step 3b: (if YES == subscribeToSelf): Our own publisher is now visible to
    // all participants in the OpenTok session. We will attempt to subscribe to
    // our own stream. Expect to see a slight delay in the subscriber video and
    // an echo of the audio coming from the device microphone.
    
    /*
    if (nil == _subscriber && subscribeToSelf)
    {
        [self doSubscribe:stream];
    }
     */
}

- (void)publisher:(OTPublisherKit*)publisher
  streamDestroyed:(OTStream *)stream
{
    
    OTSubscriber *subscriberToRemove = nil;
    for (OTSubscriber * subscriber in self.subscribers){
        
        
        if ([subscriber.stream.streamId isEqualToString:stream.streamId])
        {
            subscriberToRemove = subscriber;
            break;
            
        }
    }
    if (subscriberToRemove){
        [self cleanupSubscriber:subscriberToRemove];
    }
    [self cleanupPublisher];

    /*
    if ([_subscriber.stream.streamId isEqualToString:stream.streamId])
    {
        [self cleanupSubscriber];
    }
    
    [self cleanupPublisher];
     */
}

- (void)publisher:(OTPublisherKit*)publisher
 didFailWithError:(OTError*) error
{
    NSLog(@"publisher didFailWithError %@", error);
    [self cleanupPublisher];
}

- (void)showAlert:(NSString *)string
{
    // show alertview on main UI
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OTError"
                                                        message:string
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil] ;
        [alert show];
    });
}

@end
