const mysql = require("mysql2");
require("dotenv").config();

const connection = mysql.createConnection({
  host: "localhost",
  user: process.env.MYSQL_USERNAME,
  password: process.env.MYSQL_PASSWORD,
});



const connectDB = () => {
  return connection.connect((err) => {
    if (err) {
      console.error('Error connecting to database:', err);
      return;
    }
    console.log('Connected to database successfully');
  });
};

const runQuery = (query) => {
  connection.query(query);
}

async function execute(query, params) {
  return new Promise((resolve, reject) => {
      connection.execute(query, params, (error, results) => {
          if (error) {
              reject(error);
          } else {
              resolve(results);
          }
      });
  });
}

const retrieveData = (query, callback) =>{
  connection.query(query, (err, results) => {
    if (err) {
      console.error('Error executing query:', err);
      res.status(500).send('Error retrieving data from database');
      return;
    }
    callback(null, results);
  });
}

const setupDB = () => {
  // Create database
  const createDatabaseQuery = "CREATE DATABASE IF NOT EXISTS RIDE_SHARE;";
  connection.query(createDatabaseQuery);

  // Create Users table
  const createUsersTableQuery = `CREATE TABLE IF NOT EXISTS 
                                RIDE_SHARE.Users (
                                    UserID INT PRIMARY KEY,
                                    Name VARCHAR(100),
                                    EmailID VARCHAR(100),
                                    Phone VARCHAR(15),
                                    Password VARCHAR(500),
                                    FCMToken VARCHAR(255)
                                );`;
  runQuery(createUsersTableQuery);

  // Create Offered Rides table
  const createOfferedRidesTableQuery = `CREATE TABLE IF NOT EXISTS 
                                        RIDE_SHARE.Offered_Rides (
                                            RideID INT AUTO_INCREMENT PRIMARY KEY,
                                            DriverID INT,
                                            StartAddress POINT,
                                            DestinationAddress POINT,
                                            SeatsAvailable INT,
                                            TimeOfJourneyStart DATETIME,
                                            Polyline TEXT,
                                            FOREIGN KEY (DriverID) REFERENCES RIDE_SHARE.Users(UserID)
                                        );`;
  runQuery(createOfferedRidesTableQuery);

  // Create Requested Rides table
  const createRequestedRidesTableQuery = `CREATE TABLE IF NOT EXISTS
                                          RIDE_SHARE.RequestedRides (
                                            PassengerID INT,
                                            RideID INT,
                                            StartAddress POINT,
                                            DestinationAddress POINT,
                                            Polyline TEXT,
                                            SeatsRequested INT,
                                            PRIMARY KEY (PassengerID, RideID)
                                          );`;
  runQuery(createRequestedRidesTableQuery);

  // Create Confirmed Rides table
  const createConfirmedRidesTableQuery = `CREATE TABLE IF NOT EXISTS 
                                          RIDE_SHARE.Confirmed_Rides (
                                            RideID INT AUTO_INCREMENT PRIMARY KEY,
                                            PassengerID INT,
                                            StartAddress POINT,
                                            DestinationAddress POINT,
                                            DriverRideID INT,
                                            Polyline TEXT,
                                            FOREIGN KEY (PassengerID) REFERENCES RIDE_SHARE.Users(UserID),
                                            FOREIGN KEY (DriverRideID) REFERENCES RIDE_SHARE.Offered_Rides(RideID)
                                        );`;
  runQuery(createConfirmedRidesTableQuery);
};

module.exports = { connectDB, setupDB, runQuery, retrieveData, connection, execute};
