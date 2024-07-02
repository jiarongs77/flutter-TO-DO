# Flutter Project: DoneDeal

DoneDeal is a frontend project for users to manage (creat, add, update, delete etc) their to-do list, using the backend [FastAPI](https://github.com/jiarongs77/fastAPI-CRUD)

## User Stories

The following features are implemented:

- **Welcome Page** after app launching

- **User registration**: register account by entering email, password and full name

    - User validation for registration: The entered email address must be in the correct format, and the password must be between 4 and 10 characters long.

- **User login**: Enter the email and password to log in (an error message will be displayed if the information is incorrect)

- **To-do list management**: Displayed after logging in

    - **Add item**: add new to-do items to the list

    - **Edit item**: modify the existing item

    - **Delete item**: delete certain item by swiping left

    - **Check item**: After checking the "done" box on an item, it will be moved to the end of the list.

    - **Item ordering**: New items in the list are displayed in **reverse-chronological order**

- **Login status**: Users won't lose their login status after closing or refreshing their browser


## Tools and Library Used

- [Flutter](https://docs.flutter.dev/) : an open source framework by Google for building  multi-platform applications 

- [Postico2](https://eggerapps.at/postico2/) : visualize database tables

- [SQLite](https://docs.flutter.dev/cookbook/persistence/sqlite) : software library to persist data locally

- [JSON and serialization](https://docs.flutter.dev/data-and-backend/serialization/json) : read and parse data model

- [Shared preference](https://docs.flutter.dev/cookbook/persistence/key-value) : store small amounts of data in key-value pairs, eg. access tokens etc.

- [ChangeNotifier](https://docs.flutter.dev/data-and-backend/state-mgmt/simple#changenotifier) : manage authentication state (login/logout state)


## Video Walkthrough

Here's a walkthrough of implemented user stories:

[![Watch the video](https://img.youtube.com/vi/mFYySX9nKXY/0.jpg)](https://youtu.be/mFYySX9nKXY)

## Future Milestones

- [BLOC](https://bloclibrary.dev/architecture/) : state management library
  
- Use [Firebase](https://firebase.google.com/docs/hosting/quickstart) to deploy web app



