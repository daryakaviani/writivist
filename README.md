# Writivist

## Table of Contents
1. [Description](#Description)
2. [Features](#Features)
3. [Schema](#Schema)
4. [Credits](#Credits)
5. [License](#License)

## Description

Optimize & customize sending letters to elected officials with the objective of technologizing activism one letter at a time.

## Demo

[![Writivist Demo](https://img.youtube.com/vi/Uo7qFxssK8U/0.jpg)](https://www.youtube.com/watch?v=Uo7qFxssK8U)

## Features

* User can sign up with a new user profile.
* User can log in and out of their account.
* User can view a list of their elected officials based upon their address, sectioned off by government level.
* User can compose a letter and send it to the selected representatives.
* User can call a representative.
* User can visit the social media of a representative.
* User can visit the website of a representative.
* User can post their letter to the Template Library.
* User can switch between their profile, templates, and home scren in a tab bar.
* User can view a list of all templates, categorized.
* User can select a template and begin with that body text in the Compose view.
* User can set their profile picture in the Profile view.
* User can submit their address in the Profile view to set their location.
* User can use Google Maps SDK to view the location of the offices of each of the representatives.
* User can like a template.
* User can view the number of letters they have sent.
* User can view their total templates likes.
* User can view their total number of templates.
* User can view a list of all of their templates on the Profile view.
* User can use GPS detection to set their location.
* User can edit a template they have written.
* User can delete a template they have written.
* User can preview a template in the Template Library.
* User can view another user's profile by tapping on their profile picture in the Template Library.
* User can edit their own profile fields and save changes.
* User can see email and print availability verification checkmarks allocated towards users.
* User sees a timestamp for each template.
* User sees the number of senders of each template.
* User can see the number of cells they have selected while selecting representatives.
* User can pull to refresh their profile, Template Library, and personal templates.
* User can see a list of their representative addresses on the Find My Reps map.
* User can click to expand a section of the Template Library to view the templates in that category.
* User can search among categories in the Template Library.
* User can search among templates in the Category view.
* User can see a suggested view of popular templates at the top of the Template Library based upon their favorite categories.
* User can select whether emails are sent to elected officials individually or as a group.
* User can set one of their templates to be public or private.
* User can save a template to use later.
* User can AirPrint an automatically formatted letter for each selected representative.
* User can share a template via messages or social media.
* User experiences an onboarding tutorial upon installation.
* User can report an inappropriate template.

## Schema 

### Backend

Utilized a Parse server for the backend, saving and querying User, Template, and Report objects.

### API

The [Google Civic Information API](https://developers.google.com/civic-information/docs/v2) is utilized for representative information based upon the user address, including representative name, role, number, email, social media, address, picture, and website.

## Credits

- [AFNetworking](https://github.com/AFNetworking/AFNetworking) - networking task library
- [Parse](https://parseplatform.org/) - customizable backend
- [DateTools](https://github.com/MatthewYork/DateTools) - calculates the time ago from now
- [MBProgressHUD](https://github.com/jdg/MBProgressHUD) - activity indicators
- [IQKeyboardManager](https://github.com/hackiftekhar/IQKeyboardManager) - pushes views up with the keyboard
- [FlatIcon](flaticon.com) - icons
- [MKDropdownMenu](https://github.com/maxkonovalov/MKDropdownMenu) - Category View dropdown menu
- [GoogleMaps](https://cocoapods.org/pods/GoogleMaps) - used for Find My Reps map
- [GooglePlaces](https://cocoapods.org/pods/GooglePlaces) - used for calculating current location
- [TNTutorialManager](https://github.com/Tawa/TNTutorialManager) - onboarding tutorial
- [HWPopController](https://github.com/HeathWang/HWPopController) - report template popup

## License

    Copyright 2020 Darya Kaviani

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
