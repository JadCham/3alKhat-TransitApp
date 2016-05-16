//
//  TransitItem.h
//  GMap
//
//  Created by Jad Chamoun on 4/21/16.
//  Copyright © 2016 cibl-tcl. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMaps;

@interface TransitItem : UIViewController

@property (nonatomic, strong) NSString *stop;
@property (nonatomic, strong) NSString *route;
@property (nonatomic, strong) NSString *type;
@property double latitudeMarker;
@property double longitutdeMarker;

@end
