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
  connection.query(createUsersTableQuery);

  // Create Offered Rides table
  const createOfferedRidesTableQuery = `CREATE TABLE IF NOT EXISTS 
                                        RIDE_SHARE.Offered_Rides (
                                            RideID INT PRIMARY KEY,
                                            DriverID INT,
                                            StartAddress VARCHAR(1000),
                                            DestinationAddress VARCHAR(1000),
                                            SeatsAvailable INT,
                                            TimeOfJourneyStart DATETIME,
                                            FOREIGN KEY (DriverID) REFERENCES RIDE_SHARE.Users(UserID)
                                        );`;
  connection.query(createOfferedRidesTableQuery);

  // Create Confirmed Rides table
  const createConfirmedRidesTableQuery = `CREATE TABLE IF NOT EXISTS 
                                          RIDE_SHARE.Confirmed_Rides (
                                            RideID INT PRIMARY KEY,
                                            PassengerID INT,
                                            StartAddress VARCHAR(1000),
                                            DestinationAddress VARCHAR(1000),
                                            DriverRideID INT,
                                            FOREIGN KEY (PassengerID) REFERENCES RIDE_SHARE.Users(UserID),
                                            FOREIGN KEY (DriverRideID) REFERENCES RIDE_SHARE.Offered_Rides(RideID)
                                        );`;
  connection.query(createConfirmedRidesTableQuery);
};

module.exports = { connectDB, setupDB };
