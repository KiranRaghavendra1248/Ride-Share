const { retrieveData, connection, execute } = require("../db/connection");
const {
  buildQueryForFindRide,
  buildQueryForSubmitRide,
  convertTimeToDateTime,
  convertCoordinates,
  validatePassword,
  getLastUserID,
  updateLastUserID,
  updateLastDriverRideID,
  createBackendFiles
} = require("./utils");

const bcrypt = require('bcrypt');
const validator = require('validator');
const fs = require('fs');


const signUpUser = async (req, res) => {
  // Get parameters from request body
  console.log("Recieved API request for Sign up");
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
  console.log("Recieved API request for Login");
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
  console.log("Recieved API request for Get User Details");
  const userId = req.body.userId; // Assuming the userId is passed in the request body

  // Check if userId is provided
  if (!userId) {
    return res.status(400).json({ success: false, message: 'User ID is required' });
  }

  // Query to retrieve user details
  const sql = "SELECT * FROM RIDE_SHARE.Users WHERE UserID=?";
  const values = [userId];

  // Execute the query
  connection.query(sql, values, function (err, data) {
    if (err) {
      console.error('Error retrieving user details:', err);
      return res.status(500).json({ success: false, message: 'Internal server error' });
    } else {
      if (data.length > 0) {
        // User found, return user details
        const userDetails = {
          userId: data[0].UserID,
          name: data[0].Name,
          email: data[0].EmailID,
          phone: data[0].Phone
          // Add other user details as needed
        };
        return res.status(200).json({ success: true, message: 'User details retrieved successfully', userDetails: userDetails });
      } else {
        // User not found
        return res.status(404).json({ success: false, message: 'User not found' });
      }
    }
  });
};

const modifyUserDetails = async (req, res) => {
  console.log("Recieved API request for Modify User Details");

};


const submitRide = async (req, res) => {
  console.log("Recieved API request for Submit Ride");
  const { RideID, Date, start_latitude, start_longitude, destination_latitude, destination_longitude, startTime, numSeats, polyline, userID } = req.body;
  const DriverID = userID; // Use userID as DriverID

  const dateTime = convertTimeToDateTime(startTime, Date);

  // Correctly construct the POINT from parameters and ensure the order is (longitude, latitude)
  const startCoords = `POINT(${start_longitude} ${start_latitude})`;
  const destCoords = `POINT(${destination_longitude} ${destination_latitude})`;

  const query = buildQueryForSubmitRide(DriverID, startCoords, destCoords, numSeats, dateTime, polyline);
  try {
      const results = await execute(query, [
          DriverID,
          startCoords, 
          destCoords, 
          numSeats,
          dateTime,
          polyline
      ]);
      const maxIdQuery = "SELECT MAX(RideID) AS MaxRideID FROM RIDE_SHARE.Offered_Rides";
      const [result] = await execute(maxIdQuery); 

      const maxRideID = result['MaxRideID'];

      updateLastDriverRideID(maxRideID);

      res.status(200).json({ message: "Ride submitted successfully", RideID: maxRideID });
  } catch (error) {
      console.error('Failed to submit ride:', error);
      res.status(500).json({ error: 'Database operation failed', details: error });
  }
};


const findRides = async (req, res) => {
  console.log("Recieved API request for Find Rides");
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
  console.log("Recieved API request for Passenger Side Ride Cancellation");
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
  console.log("Recieved API request for Driver Side Ride Cancellation");

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
