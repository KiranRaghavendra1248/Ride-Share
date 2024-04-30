const express = require("express");
const cors = require("cors");
const EventEmitter = require('events'); 
const bodyParser = require('body-parser');

const rides = require("./routes_app/rides");
const { connectDB, setupDB } = require("./db/connection");
const { sendRideRequestToDriver } = require("./firebase_integration/firebaseMessaging.js")

const emitter = new EventEmitter();

require("dotenv").config();

const app = express();

const port = 3000;
const host = '0.0.0.0';

//middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

//routes
app.use("/api/v1/users", rides);

emitter.setMaxListeners(25);

const start = async () => {
  try {
    // Establish connection to MySQL Database
    const connection = await connectDB();
    console.log("Connected to MySQL Server Successfully!!");
    // Create database and setup tables
    await setupDB();
    console.log("Created RideShare DB and Created Users, Offered_Rides, Confirmed_Rides Tables Successfully!!");

    testNotification = {
        offeredRideId: "OfferedRide",
        requestedRideId: "RequestedRide"
    };
    testToken = "eU3DkrMdTJOGYJLYWs5oes:APA91bE6qA2fDsCvXRSDtCuzM933w0Y4ZFzI_yV2UNhJSW1YkFEzbWxK6UFirly5JaptBliuUauOuEXOBS3O748h5aNLwk7CphGT1qEEf6zBLGjjK5EpfyhnL3dj_ZhJg3Mkk_2JfDAH"

    sendRideRequestToDriver(testToken, testNotification)
      .then((response) => {
        console.log("Success - ", response);
      })
      .catch((error) => {
        console.log("Failure - ", error);
      });
    
    app.listen(port, host, () => {
      console.log(`Listening on port http://${host}:${port}..`);
    });
  } catch (error) {
    console.log(error);
  }
};

start();
