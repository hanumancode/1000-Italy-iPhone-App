//
//  SettingsViewController.h
//  1000 Italy
//
//  Created by Gareth Jones on 18/07/2013.
//  Copyright (c) 2013 Vitzu Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *homeBtn;

@property (strong, nonatomic) IBOutlet UIButton *compareBtn;
@property (strong, nonatomic) IBOutlet UIButton *mangiareBtn;
@property (strong, nonatomic) IBOutlet UIButton *vedereBtn;
@property (strong, nonatomic) IBOutlet UIButton *vivereBtn;

@property (strong, nonatomic) IBOutlet UIButton *profiloBtn;
@property (strong, nonatomic) IBOutlet UIButton *offerteBtn;
@property (strong, nonatomic) IBOutlet UIButton *infoutiliBtn;
@property (strong, nonatomic) IBOutlet UIButton *impostazioniBtn;
@property (strong, nonatomic) IBOutlet UIButton *qrBtn;

// tableview
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (IBAction)showOppositeView:(id)sender;
- (IBAction)togglePresentationMode:(id)sender;


-(IBAction)pushHomeButton;

-(IBAction)pushCompareButton;

-(IBAction)pushMangiareButton;

-(IBAction)pushVedereButton;

-(IBAction)pushVivereButton;
-(IBAction)pushProfiloButton;

-(IBAction)pushQRButton;

-(IBAction)pushImpostazioniButton;

-(IBAction)pushInfoUtiliButton;



@end