# StackMachine SDK for [LÖVE](http://love2d.org)

[![Build Status](https://travis-ci.org/stackmachine/stackmachine.love.png?branch=master)](https://travis-ci.org/stackmachine/stackmachine.love)

The StackMachine SDK is responsible for intgrating StackMachine and the LOVE
game engine. This SDK handles automaticac updates, crash reporting, and player
metrics.

## Usage

## API Documentation

### Automatic updates

These steps assume it's time for an update

#### Windows

- Download the new game executable, `game.exe`, for the release into the
  `updates` directory inside the save directory under new names
- Move active game file to a `oldgame.exe`, also inside the `updates` directory
- Now move the downloaded `game.exe` into the same place when the game was
  launched.
- Relaunch the game

#### OSX 

- Download the latest zipped app
- Unzip the app into the save game directory
- Remove the current app
- Move the freshly downloaded app to the old location
- Open it up

### appcast.json

The SDK checks for updates by requesting a JSON appcast from StackMachine

```js
{
  "title": "Sampel Game Appcast",
  "link": "http://cloud.example.com/appcast.json",
  "description": "Sample Description",
  "language": "en",
  "items": [{
    "title": "Version 0.1.0", 
    "published": "Sat, 03 Aug 2013 20:28:21 -0000",
    "version": "0.1.0",
    "platforms": [{
      "name": "macosx",
      "files": [{
        "url": "http://cloud.examples.com/releases/v0.1.0/game-osx.zip",
        "length": 57980508
      }]
    },{
      "name": "windows",
      "files": [{
        "url": "http://cloud.example.com/releases/v0.1.0/x86/game.exe",
        "length": 54379227
      }]
    }]
  }]
}
```

### Crash Reports

TOOD

### Player Metrics

TODO
