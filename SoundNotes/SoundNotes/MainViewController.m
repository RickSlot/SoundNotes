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

-(void) controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView beginUpdates];
}

-(void) controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView endUpdates];
}

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

-(void) fetchResults{
    NSError *error = nil;
    if(![[self fetchedResultsController] performFetch:&error]){
        NSLog(@"fetch error: %@", error);
    }
}

#pragma mark - Table view stuff

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> secInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [secInfo numberOfObjects];
}

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

- (IBAction)addButton:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New Soundnote!" message:@"Please enter the name of your new Soundnote!" delegate:self cancelButtonTitle:@"Create!" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 1;
    [alert show];
}

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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    InstrumentsTableTableViewController *itvc = (InstrumentsTableTableViewController *) [segue destinationViewController];
    itvc.managedObjectContext = self.managedObjectContext;
    NSIndexPath *ip = [self.tableView indexPathForSelectedRow];
    SoundNote *selectedSoundNote = (SoundNote *) [self.fetchedResultsController objectAtIndexPath:ip];
    itvc.soundNote = selectedSoundNote;
}




@end
