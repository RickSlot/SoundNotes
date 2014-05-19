//
//  InstrumentsTableTableViewController.m
//  SoundNotes
//
//  Created by Rick Slot on 04/05/14.
//  Copyright (c) 2014 Rick Slot. All rights reserved.
//

#import "InstrumentsTableTableViewController.h"

@interface InstrumentsTableTableViewController ()

@end

@implementation InstrumentsTableTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"instruments:");
    NSLog(@"%@", _soundNote.name);

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"items: %d", [[_soundNote.instruments allObjects] count]);
    return [[_soundNote.instruments allObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InstrumentsCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InstrumentsCell"];
    }
    
    cell.textLabel.text = [[[_soundNote.instruments allObjects]objectAtIndex:indexPath.row] name];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"showInstrument" sender:self];
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        NSLog(@"deleted object");
        [_soundNote removeInstrumentsObject:[[_soundNote.instruments allObjects]objectAtIndex:indexPath.row]];
        [self saveAndReload];
    }
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    InstrumentViewController *ivc = (InstrumentViewController *) [segue destinationViewController];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    ivc.instrument = [[_soundNote.instruments allObjects]objectAtIndex:indexPath.row];
    
    ivc.managedObjectContext = self.managedObjectContext;
    
}

- (IBAction)addInstrumentbutton:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New Instrument!" message:@"Please enter the name of your new Instrument!" delegate:self cancelButtonTitle:@"Create!" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 1;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1){
        [self createAndSaveInstrumentWithName:[[alertView textFieldAtIndex:0] text]];
    }
}

-(void)createAndSaveInstrumentWithName:(NSString *) name{
    Instruments *instrument = (Instruments *)[NSEntityDescription insertNewObjectForEntityForName:@"Instruments" inManagedObjectContext:self.managedObjectContext];
    instrument.name = name;
    instrument.soundFile = [[NSUUID UUID] UUIDString];
    [_soundNote addInstrumentsObject:instrument];
    NSLog(@"%d", [_soundNote.instruments count]);
    [self saveAndReload];
    
}

-(void) saveAndReload{
    NSError *error;
    if(![self.managedObjectContext save:&error]){
        NSLog(@"Error: %@", error);
    }else{
        [self.tableView reloadData];
    }
}




@end
