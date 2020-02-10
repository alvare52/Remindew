# WaterMyPlantsBackup


-This app lets the user sign up to our custom server. 
-Also lets them log in to said server.
-The user can add plants to their list of plants that need reminders for watering
-The reminders go off after a set amount of time has gone by, and the user can edit these plants whenever
-The plants are stored on firebase and sync with the user's phone so it is always up to date
-When there's no wifi available, the plants persist in storage
-There's a tab that lets the user view their log in credential in case they forget
-Each plant can be given a nickname, species name, time of day to remind of watering, and frequency for watering
-An alert or local notification is sent when its time to water the plant, with a message displaying which plant needs watering.
-The user can update their profile and see other users that exist, but users and plants are separate since the app is using Heroku just for users and Firebase just for plants (The Heroku server resets all users every 24 hours).
-Also, each plant's cell updates with the next date it will need to be watered. They can also be deleted from here
-I hope you all enjoy being reminded of when your beloved plants require enslaved hydration. Ok bye

Backend (Sign Up, Log In, and Update User)
https://water-my-plants-2.herokuapp.com/ 

Backend Documentation
https://github.com/Build-Week-Water-My-Plants-2/Backend

Firebase link (where plants go to be stored and loved)
https://console.firebase.google.com/project/waterplantsfirebase/database/waterplantsfirebase/data

Here's the Firebase link again in case you missed it CC
https://console.firebase.google.com/project/waterplantsfirebase/database/waterplantsfirebase/data
