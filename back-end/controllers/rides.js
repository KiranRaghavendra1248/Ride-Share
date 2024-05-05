const { retrieveData, connection } = require("../db/connection");
const {
  buildQueryForFindRide,
  convertTimeToDateTime,
  convertCoordinates,
  validatePassword,
  getLastUserID,
  updateLastUserID,
  createBackendFiles
} = require("./utils");

const bcrypt = require('bcrypt');
const validator = require('validator');
const fs = require('fs');


const signUpUser = async (req, res) => {
  // Get parameters from request body
  var name = req.body.name;
  var email = req.body.email;
  var phone = req.body.phone;
  var password = req.body.password;

  createBackendFiles();

  // Validate email
  if (!validator.isEmail(email)) {
    return res.status(400).json({ success: false, message: 'Invalid email address' });
  }

  // Validate phone number
  if (!validator.isMobilePhone(phone, 'any', { strictMode: false })) {
    return res.status(400).json({ success: false, message: 'Invalid phone number' });
  }

  // Validate password constraints
  if (!validatePassword(password)) {
    return res.status(400).json({ success: false, message: 'Invalid password' });
  }

  // Hash the password
  bcrypt.hash(password, 10, function (err, hash) {
    if (err) {
      res.status(500).json({ success: false, message: 'Error hashing password' });
    } else {
      // Fetch the last user ID and increment it to generate the new user ID
      const lastUserID = getLastUserID();
      const newUserID = lastUserID + 1;


      // Create query to insert new user
      var sqlQuery = "INSERT INTO RIDE_SHARE.Users(UserID, Name, EmailID, Phone, Password) VALUES (?, ?, ?, ?, ?)";
      var values = [newUserID, name, email, phone, hash]; // Store hashed password in the database

      // Execute query to insert new user
      connection.query(sqlQuery, values, function (error, data, fields) {
        if (error) {
          res.status(500).json({ success: false, message: error });
        } else {
          // Update the last user ID in the JSON file
          if (updateLastUserID(newUserID)) {
            res.status(201).json({ success: true, message: 'User registered successfully.', userId: newUserID });
          } else {
            res.status(500).json({ success: false, message: 'Failed to update user ID.' });
          }
        }
      });
    }
  });
};

const loginUser = async (req, res) => {
  var email = req.body.email;
  var password = req.body.password;

  // Validate email
  if (!validator.isEmail(email)) {
    return res.status(400).json({ success: false, message: 'Invalid email address' });
  }

  // Validate password
  if (!password) {
    return res.status(400).json({ success: false, message: 'Password is required' });
  }

  // Fetch user data by email
  var sql = "SELECT UserID, password FROM RIDE_SHARE.Users WHERE EmailID=?";
  var values = [email];

  connection.query(sql, values, function (err, data) {
    if (err) {
      res.status(500).json({ success: false, message: 'Internal server error' });
    } else {
      if (data.length > 0) {
        // Compare hashed password
        bcrypt.compare(password, data[0].password, function (err, result) {
          if (result) {
            res.status(200).json({ success: true, message: 'Login successful.', userId: data[0].UserID });
          } else {
            res.status(401).json({ success: false, message: 'Incorrect email or password.' });
          }
        });
      } else {
        res.status(401).json({ success: false, message: 'Incorrect email or password.' });
      }
    }
  });
};

const getUserDetails = async (req, res) => {

};

const modifyUserDetails = async (req, res) => {

};

const submitRide = async (req, res) => {
  // Suraj, the rides alli the location needs to be submitted in POINT(LNG, LAT) - it needs swapping basically
  // Use the convertCoordinates function in utils

  // Sample query
  // INSERT INTO RIDE_SHARE.Offered_Rides (RideID, DriverID, StartAddress, DestinationAddress, SeatsAvailable, TimeOfJourneyStart, Polyline) VALUES (123, 456, POINT(-116.3130661, 33.684566), POINT(-117.819771,33.742069), 3, '2024-04-25 08:00:00', 'encoded_polyline_string_here');

};

const findRides = async (req, res) => {
  const startTime = convertTimeToDateTime(req.body.startTime);
  const endTime = convertTimeToDateTime(req.body.endTime);
  const startLocation = convertCoordinates(req.body.start);
  const endLocation = convertCoordinates(req.body.destination);
  const numSeats = req.body.numSeats;
  const Polyline = req.body.polyline;

  query = buildQueryForFindRide(startTime, endTime, startLocation, endLocation, numSeats);
  retrieveData(query, (err, results) => {
    if (err) {
      // Handle error
      console.error('Error retrieving data:', err);
      res.status(500).json({ error: 'Error retrieving data' });
      return;
    }
    // Send the results back to the client
    res.status(200).json(results);
  });
};

const getRideDetails = async (req, res) => {

};

const confirmRide = async (req, res) => {

};

const riderCancelled = async (req, res) => {
  const passengerID = parseInt(req.body.passengerID, 10);
  const passengerrideID = parseInt(req.body.rideID, 10);
  retrievePassengerRideQuery = buildQueryRetrieveConfirmedRide(passengerrideID);
  retrieveData(retrievePassengerRideQuery, (err, passengerRide) => {
    if (err) {
      // Handle error
      console.error('Error retrieving data:', err);
      res.status(500).json({ error: 'Error retrieving data' });
      return;
    }
    const driverRideID = passengerRide[0].DriverRideID;
    retrieveDriverRideQuery = buildQueryRetrieveOfferedRide(driverRideID);
    retrieveData(retrieveDriverRideQuery, (err, driverRide) => {
      if (err) {
        // Handle error
        console.error('Error retrieving data:', err);
        res.status(500).json({ error: 'Error retrieving data' });
        return;
      }
      const driverID = driverRide[0].UserID;
      // Send push notification to Driver
      // sendPushNotification(driverID,"A passenger just cancelled a ride")
      console.log(driverRide);
      // Increment seats count in Offered Rides table(lets take this up later)
      // Remove entry from confirmed rides table
      deleteRideConfirmedRideTableQuery = buildQueryDeleteConfirmedRide(passengerrideID);
      console.log(deleteRideConfirmedRideTableQuery);
      try {
        runQuery(deleteRideConfirmedRideTableQuery);
      }
      catch (err) {
        console.error(err);
      }
      res.status(200);
    });
  });
};

const driverCancelled = async (req, res) => {

};

module.exports = {
  signUpUser,
  loginUser,
  getUserDetails,
  modifyUserDetails,
  submitRide,
  findRides,
  getRideDetails,
  confirmRide,
  riderCancelled,
  driverCancelled
};
