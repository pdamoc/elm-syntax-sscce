import { Elm } from "./Main.elm";

var app = Elm.Main.init({ node: document.querySelector('main') })

// This is how you subscribe to data coming from Elm 
app.ports.reportError.subscribe(err => console.log(err)); 

// This is how you send data to Elm. If the data sent fails to decode, an error will be reported to the console. 
setTimeout( _ => app.ports.fromJS.send(["10", "2"]), 2000) // call the port 2 seconds after the app started. 
