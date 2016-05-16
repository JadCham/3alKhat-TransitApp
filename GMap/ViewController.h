//
//  ViewController.h
//  GMap
//
//  Created by cibl-tcl on 8/13/15.
//  Copyright (c) 2015 cibl-tcl. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMaps;
@import GoogleMobileAds;

@interface ViewController : UIViewController <NSURLConnectionDataDelegate, NSURLConnectionDelegate, GMSMapViewDelegate,UITableViewDelegate, UITableViewDataSource>

@property NSMutableArray *detailedSteps;
@property(nonatomic,retain) CLLocationManager *locationManager;
@property NSURLConnection *cnx;
@property NSMutableData *dataResponse;
@property NSMutableArray *items;
@property (strong, nonatomic) IBOutlet GADBannerView *bannerView;
@property(nonatomic, strong) GADInterstitial *interstitial;

@end

