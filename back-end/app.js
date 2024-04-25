const express = require("express");
const cors = require("cors");
const rides = require("./routes_app/rides");
const { connectDB, setupDB, runQuery } = require("./db/connection");
const EventEmitter = require('events'); 

const emitter = new EventEmitter();

require("dotenv").config();

const app = express();

const port = 3000;

//middleware
app.use(express.json());
app.use(cors());

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
    
    app.listen(port, () => {
      console.log(`Listening on port ${port}..`);
    });
  } catch (error) {
    console.log(error);
  }
};

start();
