//
//  MainViewController.m
//  SoundNotes
//
//  Created by Rick Slot on 03/05/14.
//  Copyright (c) 2014 Rick Slot. All rights reserved.
//

#import "MainViewController.h"
#import "SoundNote.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchResults];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Fetched results controller section

/**
 * This function returns a fetchedresultscontroller instance
 */
-(NSFetchedResultsController *) fetchedResultsController{
    if(_fetchedResultsController != nil){
        return _fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SoundNote" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updated" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

/**
 * This function will notifiy the tableview that it is being updated
 */
-(void) controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView beginUpdates];
}

/**
 * This function updates the tableview when core data is updated
 */
-(void) controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView endUpdates];
}

/**
 * This function rupdates the tableview when an item is deleted or inserted
 */
-(void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
    UITableView *tableView = self.tableView;
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

/**
 * This function updates the tableview when an item is inserted
 */
-(void) controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type{
    UITableView *tableView = self.tableView;
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

/**
 * This function gets all soundnote objects from core data
 */
-(void) fetchResults{
    NSError *error = nil;
    if(![[self fetchedResultsController] performFetch:&error]){
        NSLog(@"fetch error: %@", error);
    }
}

#pragma mark - Table view stuff

/**
 * This function returns the number of sections in the tableview
 */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return [[self.fetchedResultsController sections] count];
}

/**
 * This function returns the number of rows in a section
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> secInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [secInfo numberOfObjects];
}

/**
 * This function creates the tableview with its contents
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"soundNoteCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    SoundNote *soundNote = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = soundNote.name;
    return cell;
}

/**
 * This function shows an alertview to create a new soundnote
 */
- (IBAction)addButton:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New Soundnote!" message:@"Please enter the name of your new Soundnote!" delegate:self cancelButtonTitle:@"Create!" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 1;
    [alert show];
}

/**
 * This function handles the creation of a soundnote and saves it to core data. it is also added in the tableview
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1){
        SoundNote *soundNote = (SoundNote *)[NSEntityDescription insertNewObjectForEntityForName:@"SoundNote" inManagedObjectContext:self.managedObjectContext];
        soundNote.name = [[alertView textFieldAtIndex:0] text];
        soundNote.updated = [NSDate date];
        
        NSError *error;
        if(![self.managedObjectContext save:&error]){
            NSLog(@"Error: %@", error);
        }
        
    }
}


/**
 * This function deletes a soundnote from core data when it is removed from the tableview
 */
-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        NSManagedObjectContext *context = self.managedObjectContext;
        SoundNote *noteToDelete = (SoundNote *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        [context deleteObject:noteToDelete];
        
        NSError *error = nil;
        
        if(![context save:&error]){
            NSLog(@"delete error: %@", error);
        }
    }
}

/**
 * This function passes a soundnote object to the next view
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    InstrumentsTableTableViewController *itvc = (InstrumentsTableTableViewController *) [segue destinationViewController];
    itvc.managedObjectContext = self.managedObjectContext;
    NSIndexPath *ip = [self.tableView indexPathForSelectedRow];
    SoundNote *selectedSoundNote = (SoundNote *) [self.fetchedResultsController objectAtIndexPath:ip];
    itvc.soundNote = selectedSoundNote;
}




@end
