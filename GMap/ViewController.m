#import "ViewController.h"
@import GoogleMaps;
#import "Marker.h"
#import "TransitItem.h"
#import "TransitCustomCell.h"

@interface ViewController () <GMSAutocompleteViewControllerDelegate>

@end

@implementation ViewController {
    GMSMapView *_mapView;
    BOOL _firstLocationUpdate;
    UISearchBar *searchBar;
    Marker *source;
    Marker *destination;
    Marker *userlocation;
    UIColor *RouteColor;
    NSArray *ColorArray;
    int colornumber;
    CLLocationCoordinate2D clickedcoordinates;
    UIButton *searchbutton;
    UIButton *calculatebutton;
    UIButton *clearbutton;
    UIButton *searchlocbutton;
    UIButton *uselocbutton;
    BOOL SettingSource;
    IBOutlet UIActivityIndicatorView *refreshloading;
    NSString *GoogleKey;
    UIActionSheet *_MenuSheet;
    GMSMarker *destmarker;
    GMSMarker *sourcemarker;
    UIButton *emptybutton;
    UITableView *transittableView;
    NSMutableArray *TransitItems;
    UIView *coloredProgress;
    UIView *transparentProgress;
}

@synthesize detailedSteps;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Add Banner
    self.bannerView = [[GADBannerView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-70,self.view.frame.size.width, 70)];
    self.bannerView.adUnitID = @"ca-app-pub-2911063146838974/2554982213";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    [self.view addSubview:self.bannerView];
    
    //Add loading bar
    coloredProgress = [[UIView alloc] initWithFrame:CGRectMake(0, 0,1, 20)];
    coloredProgress.backgroundColor = [UIColor colorWithRed:84.f/255.f green:190.f/255.f blue:1.f alpha:1.f];
    
    //Full screen ad
    self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-2911063146838974/8461915010"];
    GADRequest *request = [GADRequest request];
    [self.interstitial loadRequest:request];
    
    //Setup mapview and display it
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:33.892781
                                                            longitude:35.476339
                                                                 zoom:13];
    _mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height-70) camera:camera];
    _mapView.delegate = self;
    _mapView.settings.compassButton = YES;
    _mapView.settings.myLocationButton = NO;
    _mapView.accessibilityElementsHidden = NO;
    _mapView.settings.scrollGestures = YES;
    _mapView.settings.zoomGestures = YES;
    
//    UIView *StatusBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
//    StatusBar.backgroundColor = [UIColor colorWithRed:0.82 green:0.11 blue:0.13 alpha:0.6];
//    [self.view addSubview:StatusBar];
    
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(33.892781, 35.476339);
    destmarker = [GMSMarker markerWithPosition:position];
    sourcemarker = [GMSMarker markerWithPosition:position];
    
    // Listen to the myLocation property of GMSMapView.
    [_mapView addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    [self.view addSubview:_mapView];
    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        _mapView.myLocationEnabled = YES;
    });

    self.items = [NSMutableArray array];
    TransitItems = [NSMutableArray array];
    
    GoogleKey = @"YOUR_KEY_HERE";
    
    //Set default color + Random color
    UIColor *colorCombination0 = [UIColor colorWithRed:0 green:0.8 blue:0.16 alpha:0.6];
    UIColor *colorCombination1 = [UIColor colorWithRed:0.82 green:0.11 blue:0.13 alpha:0.8];
    UIColor *colorCombination2 = [UIColor colorWithRed:0 green:0.40 blue:0.07 alpha:0.6];
    UIColor *colorCombination3 = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.6];
    UIColor *colorCombination4 = [UIColor colorWithRed:1 green:0.65 blue:0 alpha:0.6];
    UIColor *colorCombination5 = [UIColor colorWithRed:0.42 green:0.11 blue:0.13 alpha:0.6];
    UIColor *colorCombination6 = [UIColor colorWithRed:0.32 green:0.11 blue:0.13 alpha:0.6];
    UIColor *colorCombination7 = [UIColor colorWithRed:0.22 green:0.11 blue:0.13 alpha:0.6];
    UIColor *colorCombination8 = [UIColor colorWithRed:0.12 green:0.11 blue:0.13 alpha:0.6];
    colornumber = 0;
    ColorArray = [[NSArray alloc] initWithObjects:colorCombination0, colorCombination1, colorCombination2, colorCombination3, colorCombination4, colorCombination5, colorCombination6, colorCombination7, colorCombination8, nil];
    
    //Calculate Button to find route
     calculatebutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [calculatebutton addTarget:self
                   action:@selector(search:)
         forControlEvents:UIControlEventTouchUpInside];
    calculatebutton.layer.cornerRadius = 18;
    calculatebutton.frame = CGRectMake(self.view.frame.size.width - 50, self.view.frame.size.height - 180, 50, 50);
    [calculatebutton setImage:[UIImage imageNamed:@"Find-Button-Normal.png"] forState:UIControlStateNormal];
    calculatebutton.hidden = TRUE;
    [calculatebutton setImage:[UIImage imageNamed:@"Find-Button-Highlighted.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [self.view addSubview:calculatebutton];
    
    //Clear Button to clear all map
    clearbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearbutton addTarget:self
                        action:@selector(clear:)
              forControlEvents:UIControlEventTouchUpInside];
    clearbutton.layer.cornerRadius = 18;
    clearbutton.frame = CGRectMake(self.view.frame.size.width - 50, self.view.frame.size.height - 180, 50, 50);
    [clearbutton setImage:[UIImage imageNamed:@"Reset-Button-Normal.png"] forState:UIControlStateNormal];
    clearbutton.hidden = TRUE;
    [clearbutton setImage:[UIImage imageNamed:@"Reset-Button-Highlighted.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [self.view addSubview:clearbutton];
    
    //Empty Button to use as background for Refresh
    emptybutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [emptybutton addTarget:self
                        action:@selector(search:)
              forControlEvents:UIControlEventTouchUpInside];
    emptybutton.layer.cornerRadius = 18;
    emptybutton.frame = CGRectMake(self.view.frame.size.width - 50, self.view.frame.size.height - 180, 50, 50);
    [emptybutton setImage:[UIImage imageNamed:@"Empty-Button-Normal.png"] forState:UIControlStateNormal];
    emptybutton.hidden = TRUE;
    [emptybutton setImage:[UIImage imageNamed:@"Empty-Button-Highlighted.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [self.view addSubview:emptybutton];
    
    //Search Button to search for locations
    searchlocbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchlocbutton addTarget:self
                    action:@selector(onLaunchClicked:)
          forControlEvents:UIControlEventTouchUpInside];
    searchlocbutton.layer.cornerRadius = 18;
    searchlocbutton.frame = CGRectMake(self.view.frame.size.width - 100, self.view.frame.size.height - 130, 50, 50);
    [searchlocbutton setImage:[UIImage imageNamed:@"Search-Button-Normal.png"] forState:UIControlStateNormal];
    [self.view addSubview:searchlocbutton];
    
    //Search Button to search for locations
    uselocbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [uselocbutton addTarget:self
                        action:@selector(taketoloc:)
              forControlEvents:UIControlEventTouchUpInside];
    uselocbutton.layer.cornerRadius = 18;
    uselocbutton.frame = CGRectMake(self.view.frame.size.width - 50, self.view.frame.size.height - 130, 50, 50);
    [uselocbutton setImage:[UIImage imageNamed:@"Location-Button-Normal.png"] forState:UIControlStateNormal];
    [self.view addSubview:uselocbutton];
    
    //Refresh Loading Indicator
    refreshloading = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshloading.layer.cornerRadius = 18;
    refreshloading.frame = CGRectMake(self.view.frame.size.width - 50, self.view.frame.size.height - 180, 50, 50);
    [self.view addSubview:refreshloading];
    
}

- (void)dealloc {
    [_mapView removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
}

#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (!_firstLocationUpdate) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        _firstLocationUpdate = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        _mapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:14];
    }
}


-(void)requestmethod:(Marker*) Marker1:(Marker*) Marker2{
    NSString *post = [NSString stringWithFormat:@"src1=%f&src2=%f&dest1=%f&dest2=%f",Marker1.latitudeMarker,Marker1.longitutdeMarker,Marker2.latitudeMarker,Marker2.longitutdeMarker];
//    NSLog(@"%@",post);
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://transit.kebbeblaban.com:8080/transit/"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(conn) {
        NSLog(@"Connection Successful");
    } else {
        NSLog(@"Connection could not be made");
    }
}

-(void)parseData:(NSData*)dataResponse
{
    NSError *error = [NSError new];
    NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:_dataResponse options:kNilOptions error:&error];

    [UIView animateWithDuration:0.5 animations:^{
            [coloredProgress setFrame:CGRectMake(0, 0,  150, 20)];
            [coloredProgress setNeedsLayout];
            [coloredProgress layoutIfNeeded];
        }];
    NSLog(@"\n\n\nfghj %f",coloredProgress.frame.size.width);
    
    NSArray *arrayOfItems = [parsedData valueForKey:@"markers"];
    
    //progressbar
    int x = 0.4;

    for(int i = 0 ; i < [arrayOfItems count] ; i++)
    {
        Marker *marker = [Marker new];
        
        marker.contentMarker = [[arrayOfItems objectAtIndex:i] valueForKey:@"title"];
        marker.longitutdeMarker = [[[arrayOfItems objectAtIndex:i] valueForKey:@"long"] doubleValue];
        marker.latitudeMarker = [[[arrayOfItems objectAtIndex:i] valueForKey:@"lat"] doubleValue];
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(marker.longitutdeMarker, marker.latitudeMarker);
        GMSMarker *newmarker = [GMSMarker markerWithPosition:position];
//        newmarker.title = marker.contentMarker;
//        if (![marker.contentMarker  isEqual: @"Source"] || ![marker.contentMarker  isEqual: @"Destination"] ){
//            newmarker.icon = [UIImage imageNamed:@"PointGreen.png"];
//        }
//        newmarker.opacity = 0.7;
//        newmarker.map = _mapView;
        
        [self.items addObject:marker];
        
        [UIView animateWithDuration:0.5 animations:^{
            [coloredProgress setFrame:CGRectMake(0, 0,  self.view.frame.size.width*(x+0.2), 20)];
            [coloredProgress setNeedsLayout];
            [coloredProgress layoutIfNeeded];
        }];
    }
    if([self.items count] <= 3){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error!" message:@"No Path is Currently Available Between These Locations." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [alertController addAction:actionOk];
        [self presentViewController:alertController animated:YES completion:nil];
        [self clearall];
    }
    else{
        [self hasFinishedLoadingData];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _dataResponse = [NSMutableData new];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_dataResponse appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error!" message:@"Please check your internet connection." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    UIAlertAction *actionTryAgain = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self requestmethod:source :destination];
    }];
    
    [alertController addAction:actionOk];
    [alertController addAction:actionTryAgain];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{

    [self parseData:_dataResponse];
}

-(void)hasFinishedLoadingData
{
    
    Marker *old = [Marker alloc];
    old = self.items[0];
    
    //Draw Source to first node route
    [self addroute: old: self.items[1]: @""];
    
//    NSMutableArray *waypoints = [NSMutableArray array];
    NSString *waypoints = @"";
    int waypointcount = 0;
    //Add all waypoints to array
    Marker *temp;
    Marker *origin;
    BOOL submittedone = FALSE;
    origin = self.items[1];
    old = self.items[1];
    NSArray *route1 = [old.contentMarker componentsSeparatedByString:@"-"];
    NSArray *route2;
    for (int i = 2; i < [self.items count]-1; i++){
        temp = self.items[i];
        route1 = [old.contentMarker componentsSeparatedByString:@"-"];
        route2 = [temp.contentMarker componentsSeparatedByString:@"-"];
        
        if (waypointcount == 26){
            [self addroute: origin: temp: waypoints];
            origin = temp;
            waypoints = @"";
            submittedone = TRUE;
        }
        else if (![route1[1] isEqualToString:route2[1]]){
            [self addroute: origin: temp: waypoints];
            origin = temp;
            waypoints = @"";
            submittedone = TRUE;
            waypointcount = 0;
        }
        
        NSString *coordinatesstring = [NSString stringWithFormat:@"%f,%f",temp.longitutdeMarker,temp.latitudeMarker];
        waypoints=[waypoints stringByAppendingString:coordinatesstring];
        waypoints=[waypoints stringByAppendingString:@"|"];
        waypointcount += 1;
        
    }
    if (!submittedone){
        [self addroute: origin: temp: waypoints];
    }
    //Draw last node t Destination route
    old = self.items[[self.items count]-2];
    [self addroute: old: self.items[[self.items count]-1]: @""];
    
//    for (int i = 1; i < [self.items count]; i++)
//    {
//        [self addroute: old:self.items[i]:@""];
//        old = self.items[i];
//    }
    [refreshloading stopAnimating];
    emptybutton.hidden = TRUE;
    clearbutton.hidden = FALSE;
    
    //Remove Loading
    [UIView animateWithDuration:0.5 animations:^{
        
        [coloredProgress setFrame:CGRectMake(0, 0,  self.view.frame.size.width, 20)];
//        [_mapView setFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height-70)];
    }];
//    [coloredProgress removeFromSuperview];
    
    //Transit tableview
    CGRect TableFrame = CGRectMake(self.view.frame.size.width - 72, 80, 72, self.view.frame.size.height-230);
    transittableView = [[UITableView alloc] initWithFrame:TableFrame];
    transittableView.delegate = self;
    transittableView.dataSource = self;
    transittableView.backgroundColor = [UIColor clearColor];
    transittableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:transittableView];
    
}

-(void)addroute:(Marker*) Marker1:(Marker*) Marker2: (NSString*) Waypoints{
    //Routes
    NSString *Mark1 = [NSString stringWithFormat:@"%f,%f",Marker1.longitutdeMarker, Marker1.latitudeMarker];
    NSString *Mark2 = [NSString stringWithFormat:@"%f,%f",Marker2.longitutdeMarker, Marker2.latitudeMarker];
    NSURL *url;
    NSString *urlstring;
    if ([Marker1.contentMarker isEqualToString:@"Source"]){
        url =[[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&mode=walking&key=%@",Mark1,Mark2,GoogleKey]];
    }
    else if([Marker2.contentMarker isEqualToString:@"Destination"]){
        url=[[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&mode=walking&key=%@",Mark1,Mark2,GoogleKey]];
    }
    else{
        if ([Waypoints isEqual:@""]){
            url=[[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&key=%@",Mark1,Mark2,GoogleKey]];
        }
        else{
            NSLog(@"MARK1 : %@ MARK2 : %@ WAYPOINTS : %@",Mark1,Mark2,Waypoints);
            urlstring = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&waypoints=%@&key=%@",Mark1,Mark2,Waypoints,GoogleKey];
            url=[[NSURL alloc] initWithString:[urlstring stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
        }
    }
    NSLog(@"LOL : %@",[url absoluteString]);
    NSURLResponse *res;
    NSError *err;
    NSData *data=[NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url] returningResponse:&res error:&err];
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    [self addDirections: dic: Marker1 :Marker2];
}

-(void)addDirections:(NSDictionary *)json : (Marker*) Marker1 : (Marker*) Marker2{
    if ([json[@"status"] isEqualToString:@"OK" ]){
        NSDictionary *routes = json[@"routes"][0];
        NSDictionary *route = routes[@"overview_polyline"];
        NSString *overview_route = route[@"points"];
        NSArray *route1 = [Marker1.contentMarker componentsSeparatedByString:@"-"];
        NSArray *route2 = [Marker2.contentMarker componentsSeparatedByString:@"-"];

        RouteColor = [ColorArray objectAtIndex:colornumber];
        if ([TransitItems count]==1){
            TransitItem *transitscell = [TransitItem new];
            transitscell.stop = route1[0];
            transitscell.route = route1[1];
            transitscell.type = @"0";
            transitscell.longitutdeMarker = Marker1.longitutdeMarker;
            transitscell.latitudeMarker = Marker1.latitudeMarker;
            [TransitItems addObject:transitscell];
        }
        if (![route1[0] isEqualToString:@"Source"] && ![route2[0] isEqualToString:@"Destination"]){
            if (![route1[1] isEqualToString:route2[1]]){
                TransitItem *transitscell = [TransitItem new];
                transitscell.stop = route2[0];
                transitscell.route = route2[1];
                transitscell.type = @"0";
                transitscell.longitutdeMarker = Marker2.longitutdeMarker;
                transitscell.latitudeMarker = Marker2.latitudeMarker;
                [TransitItems addObject:transitscell];
                RouteColor = [ColorArray objectAtIndex:colornumber];
                colornumber += 1;
            }
        }
        else if ([route1[0] isEqualToString:@"Source"]){
            TransitItem *transitscell = [TransitItem new];
            transitscell.stop = @"Start";
            transitscell.route = @"Walk";
            transitscell.type = @"1";
            transitscell.longitutdeMarker = Marker1.longitutdeMarker;
            transitscell.latitudeMarker = Marker1.latitudeMarker;
            [TransitItems addObject:transitscell];
            colornumber += 1;
        }
        else if ([route2[0] isEqualToString:@"Destination"]){
            TransitItem *transitscell = [TransitItem new];
            transitscell.stop = @"Destination";
            transitscell.route = @"Walk";
            transitscell.type = @"1";
            transitscell.longitutdeMarker = Marker2.longitutdeMarker;
            transitscell.latitudeMarker = Marker2.latitudeMarker;
            [TransitItems addObject:transitscell];
            colornumber += 1;
            RouteColor = [ColorArray objectAtIndex:colornumber];
        }
        GMSPath *path = [GMSPath pathFromEncodedPath:overview_route];
        GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
        polyline.strokeWidth = 3.0;
        polyline.strokeColor = RouteColor;
        polyline.map = _mapView;
    }
    else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error!" message:@"Something went wrong please check again later." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionTryAgain = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self clearall];
            [self setcameraoncenter];
            calculatebutton.hidden = TRUE;
            emptybutton.hidden = FALSE;
            [refreshloading startAnimating];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestmethod:source :destination];
            });
        }];
        
        [alertController addAction:actionTryAgain];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}

// Present the autocomplete view controller when the button is pressed.
- (IBAction)onLaunchClicked:(id)sender {
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.country = @"LB";
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    acController.autocompleteFilter = filter;
    [self presentViewController:acController animated:YES completion:nil];
}


- (void)viewController:(GMSAutocompleteViewController *)viewController
didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    clickedcoordinates = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude);
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:place.coordinate.latitude
                                                            longitude:place.coordinate.longitude
                                                                 zoom:15];
    [_mapView animateToCameraPosition:camera];
    clickedcoordinates = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude);
    _MenuSheet = [[UIActionSheet alloc] initWithTitle:nil
                                             delegate: self
                                    cancelButtonTitle:@"Cancel"
                               destructiveButtonTitle:nil
                                    otherButtonTitles:@"Set as Source", @"Set as Destination", nil];
    
    // Show the sheet
    [_MenuSheet showFromRect:self.view.frame inView:_mapView animated:YES];
}

- (void)viewController:(GMSAutocompleteViewController *)viewController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Error: %@", [error description]);
}

- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
-(void) mapView:(GMSMapView *) mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate{
    clickedcoordinates = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
    _MenuSheet = [[UIActionSheet alloc] initWithTitle:nil
                                             delegate: self
                                    cancelButtonTitle:@"Cancel"
                               destructiveButtonTitle:nil
                                    otherButtonTitles:@"Set as Source", @"Set as Destination", nil];
    
    // Show the sheet
    [_MenuSheet showFromRect:self.view.frame inView:_mapView animated:YES];
    
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0){
        [self setsource];
    }
    else if (buttonIndex == 1){
        [self setdestination];
    }
    else if (buttonIndex == 2){
        
    }
}

-(void) setsource{
    source = [Marker new];
    source.contentMarker = @"Source";
    source.latitudeMarker = clickedcoordinates.latitude;
    source.longitutdeMarker = clickedcoordinates.longitude;
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(clickedcoordinates.latitude, clickedcoordinates.longitude);
    sourcemarker.position = position;
    sourcemarker.opacity = 0.7;
    UIImage *markernotsized = [UIImage imageNamed:@"marker.png"];
    sourcemarker.icon = [self imageWithImage:markernotsized scaledToSize:CGSizeMake(35, 35)];
    sourcemarker.map = _mapView;
    SettingSource = FALSE;
//    GMSCameraUpdate *camera =  [GMSCameraUpdate setTarget:clickedcoordinates zoom:15];
//    [_mapView animateWithCameraUpdate:camera];
    NSLog(@"%f %f",_mapView.myLocation.coordinate.latitude,_mapView.myLocation.coordinate.longitude);
    
}

-(void)setdestination{
    destination = [Marker new];
    destination.contentMarker = @"Destination";
    destination.latitudeMarker = clickedcoordinates.latitude;
    destination.longitutdeMarker = clickedcoordinates.longitude;
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(clickedcoordinates.latitude, clickedcoordinates.longitude);
    destmarker.position = position;
    UIImage *markernotsized = [UIImage imageNamed:@"marker.png"];
    destmarker.icon = [self imageWithImage:markernotsized scaledToSize:CGSizeMake(35, 35)];
    destmarker.opacity = 0.7;
    destmarker.map = _mapView;
    calculatebutton.hidden = FALSE;
//    GMSCameraUpdate *camera =  [GMSCameraUpdate setTarget:clickedcoordinates zoom:15];
//    [_mapView animateWithCameraUpdate:camera];
}

- (IBAction)taketoloc:(id)sender {
    clickedcoordinates = CLLocationCoordinate2DMake(_mapView.myLocation.coordinate.latitude, _mapView.myLocation.coordinate.longitude);
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:_mapView.myLocation.coordinate.latitude
                                                            longitude:_mapView.myLocation.coordinate.longitude
                                                                 zoom:15];
    [_mapView animateToCameraPosition:camera];
    _MenuSheet = [[UIActionSheet alloc] initWithTitle:nil
                                             delegate: self
                                    cancelButtonTitle:@"Cancel"
                               destructiveButtonTitle:nil
                                    otherButtonTitles:@"Set as Source", @"Set as Destination", nil];
    
    // Show the sheet
    [_MenuSheet showFromRect:self.view.frame inView:_mapView animated:YES];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)setcameraoncenter{
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];
    
    bounds = [bounds includingCoordinate:sourcemarker.position];
    bounds = [bounds includingCoordinate:destmarker.position];
    
    [_mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:30.0f]];
    

}

- (IBAction)search:(id)sender {
    if (source == nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't find path"
                                                        message:@"You must specify a source point to go from."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        destination = nil;
    }
    else{
        [self setcameraoncenter];
        calculatebutton.hidden = TRUE;
        emptybutton.hidden = FALSE;
        [refreshloading startAnimating];
        //start loading
        [self.view addSubview:coloredProgress];
        [UIView animateWithDuration:0.5 animations:^{
            [coloredProgress setFrame:CGRectMake(0, 0,  self.view.frame.size.width*(0.2), 20)];
            [_mapView setFrame:CGRectMake(0, 20,self.view.frame.size.width, self.view.frame.size.height-70)];
        }];
        if ([self.interstitial isReady]) {
            [self.interstitial presentFromRootViewController:self];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self requestmethod:source :destination];
        });
    }
}

//Button action to clear all
- (IBAction)clear:(id)sender {
    [self clearall];
}

//Method to clear all and start new search
-(void)clearall{
    [_mapView clear];
    [sourcemarker setOpacity:0.0];
    [destmarker setOpacity:0.0];
    calculatebutton.hidden = TRUE;
    SettingSource = TRUE;
    source = nil;
    destination = nil;
    SettingSource = TRUE;
    clearbutton.hidden = TRUE;
    transittableView.hidden = TRUE;
    [refreshloading stopAnimating];
    emptybutton.hidden = TRUE;
    [self.items removeAllObjects];
    [TransitItems removeAllObjects];
    colornumber = 0;
    
}

//TABLE VIEW RELATED
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    return [TransitItems count];
}

// the cell will be returned to the tableView
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"HistoryCell";
    TransitCustomCell *cell = (TransitCustomCell *)[theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[TransitCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    TransitItem *item = [TransitItems objectAtIndex:indexPath.row];
    cell.stopname.text = item.stop;
    cell.routename.text = item.route;
    cell.backgroundColor = [ColorArray objectAtIndex:indexPath.row];
    cell.contentView.backgroundColor = [ColorArray objectAtIndex:indexPath.row];
    if ([item.type  isEqual: @"1"]){
        UIImage *walk = [UIImage imageNamed:@"walk.png"];
        [cell.Action setImage:walk];
    }
    else{
        UIImage *bus = [UIImage imageNamed:@"bus.png"];
        [cell.Action setImage:bus];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
// when user tap the row, what action you want to perform
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TransitItem *item = [TransitItems objectAtIndex:indexPath.row];
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(item.longitutdeMarker, item.latitudeMarker);
    GMSCameraUpdate *camera =  [GMSCameraUpdate setTarget:position zoom:15];
    [_mapView animateWithCameraUpdate:camera];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
@end