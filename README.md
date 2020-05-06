# A Short, Self Contained, Correct (Compilable), Example for the entire Elm syntax. 

This project started as a playful attempt to implement a short example that covers the entire Elm syntax. 

The current version runs in [this Ellie](https://ellie-app.com/8MKgxxwxSW2a1).

The phantom types and WebGL Shader language examples are dead code (code that isn't used inside the app).

For a working example of WebGL Shader language see the [elm-explorations/webgl examples](https://github.com/elm-explorations/webgl/tree/master/examples).

## Running the example localy

The repository uses `parcel` as a build manager. The JS code is in [src/app.js](src/app.js). 

    npm install 
    npm start 

## Warnings 

It could be useful to look at the warnings that [elm-analyse](https://github.com/stil4m/elm-analyse) produces on this example. 

There are some recommendations against using some of the patterns presented here (e.g. import all from module). Most of the warnings are for unused code. 