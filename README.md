#writivist

##Table of Contents

Overview
Product Spec
Wireframes
Schema
Overview

Description

Optimize & customize sending letters to politicians for activism at your fingertips.

App Evaluation

Category: Activism
Mobile: Potential mobile features include the ability to take pictures of a printed letter to upload, the ability to upload your profile picture internally, and even the ability to use GPS functionality to determine the user's location without necessitating address input. Story:
Simplicity - Because of the Template Library and the ease of finding your politicians, users are inclined to send emails to contribute to advocacy.
Customizability - When large templates go around, politicians often use blockers to funnel all emails with a certain subject or body to a folder they don't look at. Customizability allows templates to be adjusted so all emails are actually read and thoroughly processed by staff.
Market: The market is anyone interested in activism whatsoever. The inexperienced will benefit from the simplicity and the experienced will benefit from the uniqueness of the customizability.
Habit: People can most definitely use this habitually. Once they recognize and experience the pure simplicity of the application, they will be able to form a habit out of reaching out to their politicians as often as possible. Addictive features can include infinite scrolling in the template library, minimalistic and beautiful UI, and potentially even rewards points to incline users to write more.
Scope: The scope is very dependent. It would not be too challenging to build the client that sends the emails, but adding GPS, storing the template library, finding the right API for representatives, as well as adding on additional features could be challenging.
Product Spec

1. User Stories (Required and Optional)

Required Must-have Stories

User can sign up with a new user profile.
User can log in and out of their account.
User can view a list of their elected officials based upon their address.
User can compose a letter and send it to the selected representatives.
User can save their letter to the Template Library.
User can switch between their profile, templates, and home scren in a tab bar.
User can view a list of all templates, categorized.
User can select a template and begin with that body text in the Compose view.
User can submit their address in the Profile view to set their location.
User can set their profile picture in the Profile view.
User can use Google Maps SDK to view their location.
Optional Nice-to-have Stories

User can like a template.
User can add tags to template.
User can see a recommended view of suggested templates based on past keywords.
User can view the number of letters they have sent.
User can view their total templates likes.
User can view their total number of templates.
User can view a list of all of their templates on the Profile view.
User can use GPS detection to set their location.
User can edit a template they have written.
User can delete a template they have written.
User can comment on a template.
User can either take a photo to detect the writing on a prewritten letter or upload a PDF document.

2. Screen Archetypes

Login Screen
User can Login.
Choose Path Screen
User can determine whether they want to write from scratch or use the template library.
Template Library
After selecting to use the template library path, users are met with a table view of templates. Type in keywords to the search bar to select a template that suits your needs, modify to your liking, and send.
Compose Screen
User can write the body of the message (either from scratch or already incorporating a template) and send. You can choose to also submit this template to the Template Library of Writivism.
Profile Screen (Stretch)
Includes the number of letters sent, profile picture, location, and potentially rewards points.

3. Navigation

Tab Navigation (Tab to Screen)

Template Feed
Profile
Write Letter (Home)
Flow Navigation (Screen to Screen)

Login Screen
=> Home
Write Letter (Home)
=> Choose Path Screen
Choose Path Screen + Template Library
=> Choose Template Library
=> Pick Template
=> Compose Message
Choose From Scratch
=> Compose Message
Wireframes

Work in Progress: https://www.figma.com/file/paTyAfiEkzWdTvL2JOXDej/writivist?node-id=0%3A1 
Schema

Models

User

Property	Type	Description
objectId	String	unique id for the user (default field)
templates	Array	series of templates uploaded by the user
location	String	current inputted location of the user
profilePicture	File	user's profile picture
likeCount	Number	number of likes acquired by the user's templates
templateCount	Number	number of templates posted by the user
letterCount	Number	number of letters sent by the user
createdAt	DateTime	date when the user account is created (default field)
updatedAt	DateTime	date when the user account is last updated (default field)

Template

Property	Type	Description
objectId	String	unique id for the template (default field)
author	Pointer to User	template author
likeCount	Number	number of likes the template has acquired
category	String	category of the template (environmental justice, racial justice, etc.)
body	String	contents of the letter
title	String	title of the letter
createdAt	DateTime	date when the template is created (default field)
updatedAt	DateTime	date when the template is last updated (default field)
Networking

Network Request Outline

Login

(Create/POST) Create a new user
[newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
    //perform segue
}];
Template Library

(Read/GET) Get the templates
Title
Likes
Author
Category
PFQuery *query = [PFQuery queryWithClassName:@"Template"];
[query orderByDescending:@"createdAt"];
query.limit = 30;
[query findObjectsInBackgroundWithBlock:^(NSArray *templates, NSError *error) {
    if (templates != nil) {
        self.templates = templates;
        [self.tableView reloadData];
    } else {
        NSLog(@"%@", error.localizedDescription);
    }
}];
(Create/Post) Like a template //will do once i figure out how liking works for instagram!
Compose

(Create/Post) If saved to template library is selected, make a new template
Template *newTemplate = [Template new];
newTemplate.author = [PFUser currentUser];
newTemplate.category = category;
newTemplate.body = body;
newTemplate.title = title;
newPost.likeCount = @(0);
[newPost saveInBackgroundWithBlock: completion];
Profile

(Read/GET) Get the User
Name
Profile Picture
Letter count
Current location
Here, we can use [PFUser currentUser] to access the current logged-in user.

(Create/POST or Update/PUT) Set your profile picture
[PFUser.currentUser setObject:self.pickerView forKey:@"profilePic"];
[PFUser.currentUser saveInBackground];
(Create/POST or Update/PUT) Set your location
[PFUser.currentUser setObject:self.location forKey:@"location"];
[PFUser.currentUser saveInBackground];
APIs

Need an API to GET list of elected officials for each user's location. Looking into the Civic API and the Smarty Streets Geocoding API.
