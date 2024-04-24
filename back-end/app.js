const express = require("express");
const { connectDB, setupDB, runQuery } = require("./db/connection");
require("dotenv").config();

const port = 3000;
const app = express();

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
