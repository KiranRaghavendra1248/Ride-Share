const mysql = require("mysql2");
require("dotenv").config();

const connection = mysql.createConnection({
  host: "localhost",
  user: process.env.MYSQL_USERNAME,
  password: process.env.MYSQL_PASSWORD,
});

const connectDB = () => {
  return connection.connect();
};

const runQuery = (query) => {
  connection.query(query);
}

const setupDB = () => {
  // Create database
  const createDatabaseQuery = "CREATE DATABASE IF NOT EXISTS RIDE_SHARE;";
  connection.query(createDatabaseQuery);

  // Create Users table
  const createUsersTableQuery = `CREATE TABLE IF NOT EXISTS 
                                RIDE_SHARE.Users (
                                    UserID INT PRIMARY KEY,
                                    FirstName VARCHAR(50),
                                    LastName VARCHAR(50),
                                    EmailID VARCHAR(100),
                                    CountryCode VARCHAR(5),
                                    PhoneNumber VARCHAR(15)
                                );`;
  runQuery(createUsersTableQuery);

  // Create Offered Rides table
  const createOfferedRidesTableQuery = `CREATE TABLE IF NOT EXISTS 
                                        RIDE_SHARE.Offered_Rides (
                                            RideID INT PRIMARY KEY,
                                            DriverID INT,
                                            StartAddress POINT,
                                            DestinationAddress POINT,
                                            SeatsAvailable INT,
                                            TimeOfJourneyStart DATETIME,
                                            Polyline TEXT,
                                            FOREIGN KEY (DriverID) REFERENCES RIDE_SHARE.Users(UserID) ON DELETE CASCADE
                                        );`;
  runQuery(createOfferedRidesTableQuery);

  // Create Confirmed Rides table
  const createConfirmedRidesTableQuery = `CREATE TABLE IF NOT EXISTS 
                                          RIDE_SHARE.Confirmed_Rides (
                                            RideID INT PRIMARY KEY,
                                            PassengerID INT,
                                            StartAddress POINT,
                                            DestinationAddress POINT,
                                            DriverRideID INT,
                                            Polyline TEXT,
                                            FOREIGN KEY (PassengerID) REFERENCES RIDE_SHARE.Users(UserID) ON DELETE CASCADE,
                                            FOREIGN KEY (DriverRideID) REFERENCES RIDE_SHARE.Offered_Rides(RideID) ON DELETE CASCADE
                                        );`;
  runQuery(createConfirmedRidesTableQuery);
};

module.exports = {connectDB, setupDB, runQuery};
