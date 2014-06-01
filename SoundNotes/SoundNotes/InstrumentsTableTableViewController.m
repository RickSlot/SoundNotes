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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

/**
 * This function returns 1 because we only have one section in the tableview
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/**
 * This function returns how many items are in the tableview
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_soundNote.instruments allObjects] count];
}

/**
 * This function creates the tableview with the given content
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InstrumentsCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InstrumentsCell"];
    }
    
    cell.textLabel.text = [[[_soundNote.instruments allObjects]objectAtIndex:indexPath.row] name];
    return cell;
}

/**
 * This function loads the next view with the selected instrument
 */
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"showInstrument" sender:self];
}

/**
 * This function removes a deleted item from the tableview and also removes it from core data
 */
-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        [_soundNote removeInstrumentsObject:[[_soundNote.instruments allObjects]objectAtIndex:indexPath.row]];
        [self saveAndReload];
    }
}

/**
 * This function passes an soundnote object and a managedcontext to the next view
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    InstrumentViewController *ivc = (InstrumentViewController *) [segue destinationViewController];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    ivc.instrument = [[_soundNote.instruments allObjects]objectAtIndex:indexPath.row];
    
    ivc.managedObjectContext = self.managedObjectContext;
    
}

/**
 * This function shows an alertview when the + button is clicked
 */
- (IBAction)addInstrumentbutton:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New Instrument!" message:@"Please enter the name of your new Instrument!" delegate:self cancelButtonTitle:@"Create!" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 1;
    [alert show];
}

/**
 * This function handles the input of the alertview
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1){
        [self createAndSaveInstrumentWithName:[[alertView textFieldAtIndex:0] text]];
    }
}

/**
 * This function creates a new instrument with the given name and saves it to core data
 */
-(void)createAndSaveInstrumentWithName:(NSString *) name{
    Instruments *instrument = (Instruments *)[NSEntityDescription insertNewObjectForEntityForName:@"Instruments" inManagedObjectContext:self.managedObjectContext];
    instrument.name = name;
    instrument.soundFile = [[NSUUID UUID] UUIDString];
    [_soundNote addInstrumentsObject:instrument];
    [self saveAndReload];
    
}

/**
 * This function saves the objects to core data and reloads the tableview
 */
-(void) saveAndReload{
    NSError *error;
    if(![self.managedObjectContext save:&error]){
        NSLog(@"Error: %@", error);
    }else{
        [self.tableView reloadData];
    }
}




@end
