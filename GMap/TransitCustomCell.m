//
//  TransitCustomCell.m
//  GMap
//
//  Created by Jad Chamoun on 4/21/16.
//  Copyright © 2016 cibl-tcl. All rights reserved.
//

#import "TransitCustomCell.h"

@implementation TransitCustomCell

@synthesize stopname = _stopname;
@synthesize Action = _Action;
@synthesize routename = _routename;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // configure control(s)
        self.stopname = [[UILabel alloc] initWithFrame:CGRectMake(0, -8, 70, 30)];
        self.stopname.textColor = [UIColor blackColor];
        self.stopname.font = [UIFont fontWithName:@"Arial" size:12.0f];
        self.stopname.adjustsFontSizeToFitWidth=YES;
        [self.stopname setTextAlignment:UITextAlignmentCenter];
        [self addSubview:self.stopname];
        
        //create an image
        UIImage *myScreenShot = [UIImage imageNamed:@"bus.png"];
        self.Action = [[UIImageView alloc] initWithImage:myScreenShot];
        CGRect myFrame = CGRectMake(0, 12.0f, 70, 40);
        [self.Action setFrame:myFrame];
        [self.Action setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:self.Action];
        
        self.routename = [[UILabel alloc] initWithFrame:CGRectMake(0, 42, 70, 30)];
        self.routename.textColor = [UIColor blackColor];
        self.routename.adjustsFontSizeToFitWidth=YES;
        self.routename.font = [UIFont fontWithName:@"Arial" size:12.0f];
        [self.routename setTextAlignment:UITextAlignmentCenter];
        [self addSubview:self.routename];
    }
    return self;
}

@end
