//
//  TransitCustomCell.h
//  GMap
//
//  Created by Jad Chamoun on 4/21/16.
//  Copyright © 2016 cibl-tcl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransitCustomCell : UITableViewCell

// now only showing one label, you can add more yourself
@property (nonatomic, strong) UILabel *stopname;
@property (nonatomic, strong) UILabel *routename;
@property (nonatomic, strong) UIImageView *Action;

@end
