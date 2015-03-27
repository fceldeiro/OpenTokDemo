//
//  MainViewController.m
//  OpenTokDemo
//
//  Created by Fabian Celdeiro on 3/27/15.
//  Copyright (c) 2015 Fabian Celdeiro. All rights reserved.
//

#import "MainViewController.h"
#import "ViewController.h"




static NSString*  kTokenA = @"T1==cGFydG5lcl9pZD00NTE5MTA0MiZzaWc9YWU3YmIyNWY5NzAzZDJmZTc2ZDA2NDMyMWNlMDY4YThjN2UyZjU5ZTpyb2xlPXB1Ymxpc2hlciZzZXNzaW9uX2lkPTFfTVg0ME5URTVNVEEwTW41LU1UUXlOek14TlRRMU1UVXlOMzQ1V25selRWZFlhRUpKU2twa1JrdzNXR1ZyTTBsR01UVi1mZyZjcmVhdGVfdGltZT0xNDI3NDg5NjU0Jm5vbmNlPTAuMjYxNzMyNDczMzEyNDUyNzUmZXhwaXJlX3RpbWU9MTQzMDA4MTU1OA==";

static NSString * kTokenB = @"T1==cGFydG5lcl9pZD00NTE5MTA0MiZzaWc9MDQ3MWFhNDdkYzgyNjQyNGU2YzI3Y2I4YzZlMjIxYjZiNjkyNzNhYTpyb2xlPXB1Ymxpc2hlciZzZXNzaW9uX2lkPTFfTVg0ME5URTVNVEEwTW41LU1UUXlOek14TlRRMU1UVXlOMzQ1V25selRWZFlhRUpKU2twa1JrdzNXR1ZyTTBsR01UVi1mZyZjcmVhdGVfdGltZT0xNDI3NDg5NjY1Jm5vbmNlPTAuMjA5MzU1ODIwMjYxMjA1MTQmZXhwaXJlX3RpbWU9MTQzMDA4MTU1OA==";

static NSString * kTokenC = @"T1==cGFydG5lcl9pZD00NTE5MTA0MiZzaWc9YTY5YmY3MTljNjg1MTM5MzZhYmY0ZGEyZGQ1N2FmOTcxYjYzNjBjZTpyb2xlPXB1Ymxpc2hlciZzZXNzaW9uX2lkPTFfTVg0ME5URTVNVEEwTW41LU1UUXlOek14TlRRMU1UVXlOMzQ1V25selRWZFlhRUpKU2twa1JrdzNXR1ZyTTBsR01UVi1mZyZjcmVhdGVfdGltZT0xNDI3NDg5Njc0Jm5vbmNlPTAuMjE2ODIzNjAwNjEwODM3ODMmZXhwaXJlX3RpbWU9MTQzMDA4MTU1OA==";



@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"segueCreateSessionForUserA"]){
        if ([segue.destinationViewController isKindOfClass:[ViewController class]]){
            ViewController* controller =  (ViewController*) segue.destinationViewController;
            controller.userToken = kTokenA;
        }

    }
    else if ([segue.identifier isEqualToString:@"segueCreateSessionForUserB"]){
        if ([segue.destinationViewController isKindOfClass:[ViewController class]]){
            ViewController* controller =  (ViewController*) segue.destinationViewController;
            controller.userToken = kTokenB;
        }
        
    }
    else if ([segue.identifier isEqualToString:@"segueCreateSessionForUserC"]){
        if ([segue.destinationViewController isKindOfClass:[ViewController class]]){
            ViewController* controller =  (ViewController*) segue.destinationViewController;
            controller.userToken = kTokenC;
        }
        
    }


}


@end
