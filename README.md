# World of Warcraft Random Dungeon Group Generator

## Introduction

Hello!

This application, in simple terms, is a way to input a list of characters/people as well as what roles they play in WoW,
and create dungeon groups with those players distributed randomly. I am the GM and Raid Leader of the guild Ashen Phoenix on Sen'jin,
and I had multiple goals/reasons for building this project.

- To increase the interactions between all the people on my raid team, and promote community across the entire team
- To make sure that some of our lower skilled players were enabled to run higher level keys for better gear
- To push my team to playing difficult content outside of raid to help increase their skill level

## How it works

### Character Set Up

Before you generate groups, you need to set up the people the generator will select from.

There are multiple settings you can select for each person.

- The roles they would like to play:
  - Tank
  - Healer
  - Melee Dps
  - Ranged Dps
- If they would like to be able to be selected for multiple groups (more on this later)
- Their skill level

Once you have set the characters up successfully, you can generate groups.

### Generating Groups

The system has a psuedo-priority list when calculating who should be in what group. Here is a rundown of the order of operations when generating groups.

- Select one low-skilled player to be placed in each group with a role randomly selected from their list of available roles.
- Select one high-skilled player to be placed in each group with a role randomly selected from their list of available roles.
- Select one tank for each group, unless there is already a tank for that group. This will prioritize people who have only selected tank as their role.
- Select one healer for each group, unless there is already a healer for that group. This will prioritize people who have not selected any dps roles.
- Select one ranged dps for each group, unless there are no more ranged to select from, or the group's dps list is full.
- Select one melee dps for each group, unless there are no more melee to select from, or the group's dps list is full.
- Take all the people not selected for the main groups and place them in a fill group, with roles selected randomly from their list of available roles.
- Fill the remaining slots in the fill group with people who have allow multiple groups selected.

### Empty Slots

Sometimes, the system is unable to fill a slot even with the fill group. If that happens, the slot will be listed as Empty.
You can either find someone to fill that slot yourself, or simply refresh the page to have it generate new groups. This is usually
caused by not enough people allowing multiple groups.

## Hosting with Heroku

The easiest way to set this app up to run for your own group is to host on heroku for free. Simply follow these instructions, and you'll have
your own app up and running in no time.

### Creating a Heroku Account

If you already have a heroku account, feel free to skip this step.

To set up a heroku account, follow these steps.
- Go to [heroku.com](https://www.heroku.com) and click the Sign up link in the top right hand corner.
- Fill out the account creation form.
- You will receive an email with a confirmation link. Go follow that link.
- You will then be asked to set a password. Do that.

### Creating the app

Now that you're set up with an account, you need to create an app that will track this GitHub repository.

- Click the button that says "Create new app"
- Give your app a name. Use something descriptive that you'll remember. The app name will be a part of the link to get to your site.

Next, for you to have heroku track this app, you need to have your own fork of the app.
Simply click the fork button at the top of this page and follow it's instructions.

Next, we need to set the heroku app to track the fork you just made.

- In heroku, on the Deploy tab, click the GitHub button under Deployment method.
- You'll be asked to log in to GitHub to connect your account to heroku.
- Once that's done, there will be a section titled "Connect to GitHub". Just start typing in the name of your forked repo in the repo-name box and hit search.
- You should see your forked repo pop up under that box.
- Next, scroll down a bit and Hit Enable Automatic Deploys
- Lastly, scroll all the way down and manually deploy the current Master branch. You'll see a box pop up and scroll through a bunch of stuff. Once that's done, move on to the next section.

### Setting up the Database

At this point the app is ready to go, except we need to set up the database.

- Scroll up to the top of the page and click the button that says "More"
- Select the option "Run console"
- in the window that pops up, paste the following command and hit run: `rake db:schema:load`

Once that's finished, you're ready to roll!
Simply click the "Open app" button at the top of the page to go to your new app and start setting up characters.
