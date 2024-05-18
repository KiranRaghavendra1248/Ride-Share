const { retrieveData, connection, execute } = require("../db/connection");
const { sendRideRequestToDriver, sendRideConfirmationToRider, sendRideRejectionToRider } = require("../firebase_integration/firebaseMessaging");
const {
  buildQueryForFindRide,
  buildQueryForSubmitRide,
  convertTimeToDateTime,
  convertTimeToDateTime_Suraj,
  convertCoordinates,
  validatePassword,
  getLastUserID,
  updateLastUserID,
  updateLastDriverRideID,
  createBackendFiles,
  buildQueryRetrieveOfferedRide,
  buildQueryRetrieveUserDetails,
  buildQueryForPassengerActiveRides,
  buildQueryRetrieveUserDetailswithDriverRideID
} = require("./utils");

const bcrypt = require('bcrypt');
const validator = require('validator');
const fs = require('fs');
const moment = require('moment');


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
  console.log(req.body);

  var email = req.body.email.toString();
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

const updateFcmToken = async (req, res) => {
    var userId = req.body.user;
    var token = req.body.fcmToken;

    console.log("Update FCM Token API hit for", userId);

    var updateSql = `UPDATE RIDE_SHARE.Users SET FCMToken = ? WHERE UserID = ?`

    connection.query(updateSql, [token, userId], (err, data) => {
        if (err) {
            console.log(err.message)
            return res.status(500).send('Failed to update FCMToken');
        }
    });
}

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
  const { Date, start_latitude, start_longitude, destination_latitude, destination_longitude, startTime, numSeats, polyline, userID } = req.body;
  const DriverID = userID; // Use userID as DriverID

  console.log(Date)
  const dateTime = convertTimeToDateTime_Suraj(startTime, Date);
  console.log(dateTime)

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

const driverActiveRides = async (req, res) => {
  console.log("Recieved API Request for Driver Active Rides");
  const { userID } = req.body;
  if (!userID) {
    return res.status(400).json({
      message: "UserID is required"
    });
  }
  // Using parameterized queries to prevent SQL injection
  const query = `SELECT 
  RideID, DriverID, StartAddress, DestinationAddress, SeatsAvailable, DATE_FORMAT(TimeOfJourneyStart, '%Y-%m-%d %H:%i:%s') AS JourneyStart 
  FROM RIDE_SHARE.Offered_Rides 
  WHERE DriverID = ${userID} AND TimeOfJourneyStart > NOW();`;

  retrieveData(query, (err,results) => {
    if(err){
      console.error("Error retrieving Driver Active Rides");
      res.status(500).json({ error: 'Error retrieving data' });
      return;
    }
    if(0 == results.length){
      response = {
        "message" : "No rides available"
      }
      return res.status(200).json(response);
    }
    console.log(results);
    return res.status(200).json(results);
  })
};

const passengerActiveRides = async (req, res) => {
  console.log("Recieved API Request for Passenger Active Rides")
  const userId = req.body.userID; 
  const query = buildQueryForPassengerActiveRides(userId);
  retrieveData(query, (err, results) => {
    if (err) {
      // Handle error
      console.error('Error retrieving data:', err);
      res.status(500).json({ error: 'Error retrieving data' });
      return;
    }
    if(0 == results.length){
      response = {
        "message" : "No rides available"
      }
      return res.status(200).json(response);
    }
    driverRideIDs = [];
    for(let i = 0; i < results.length; i++){
      driverRideIDs.push(results[i]['DriverRideID']);
    }
    getUserDetailsQuery = buildQueryRetrieveUserDetailswithDriverRideID(driverRideIDs);
    retrieveData(getUserDetailsQuery, (err1, results1) =>{
      if(err1){
        console.error('Error retrieving data:', err1);
        res.status(500).json({ error: 'Error retrieving data' });
        return;
      }
      for(let i = 0; i < results.length; i++){
        for(let j = 0; j < results1.length; j++){
          if(results[i]['DriverRideID'] == results1[j]['DriverRideID']){
            results[i]['driverDetails'] = results1[j];
          }
        }
      }
      return res.status(200).json(results);
    })
})
}

const viewPassengers = async (req, res) => {
  console.log("Received API request for View Passengers")
  const {userID} = req.body
};



const findRides = async (req, res) => {
  console.log("Recieved API request for Find Rides");
  const passengerID = req.body.userID;
  const startTime = convertTimeToDateTime(req.body.startTime);
  const endTime = convertTimeToDateTime(req.body.endTime);
  const startLocation = convertCoordinates(req.body.start);
  const endLocation = convertCoordinates(req.body.destination);
  const numSeats = req.body.numSeats;
  const threshold = 4800; // roughly 3 miles

  query = buildQueryForFindRide(startTime, endTime, startLocation, endLocation, numSeats, threshold, passengerID);
  retrieveData(query, (err, results) => {
    if (err) {
      // Handle error
      console.error('Error retrieving data:', err);
      res.status(500).json({ error: 'Error retrieving data' });
      return;
    }
    console.log(results,results.length);
    userIDs = [];
    for(let i = 0; i < results.length; i++){
      userIDs.push(results[i]['DriverID']);
    }
    if(0 == results.length){
      response = {
        "message" : "No rides available"
      }
      return res.status(200).json(response);
    }
    getUserDetailsQuery = buildQueryRetrieveUserDetails(userIDs);
    retrieveData(getUserDetailsQuery, (err, userDetails) => {
      if (err) {
        // Handle error
        console.error('Error retrieving data:', err);
        res.status(500).json({ error: 'Error retrieving data' });
        return;
      }
      for(let i = 0; i < results.length; i++){
        results[i]['distance_in_meters'] = parseInt(results[i]['distance_in_meters']);
        for(let j = 0; j < userDetails.length; j++){
          if(results[i]['DriverID'] == userDetails[j]['UserID']){
            results[i]['driverDetails'] = userDetails[j];
          }
        }
      }
      // Send the results back to the client
      console.log(results);
      return res.status(200).json(results);
    });
  });
};

const requestRide = async (req, res) => {
  console.log("Recieved API request for Request Ride");
  const riderId = req.body.userID;
  const selectedRideId = req.body.rideID;
  const startLocation = convertCoordinates(req.body.start);
  const endLocation = convertCoordinates(req.body.destination);
  const polyLine = req.body.polyLine;
  const numSeats = req.body.numSeats;


  // verify if the selectedRideId is valid
  retrieveDriverRideQuery = buildQueryRetrieveOfferedRide(selectedRideId);
  retrieveData(retrieveDriverRideQuery, (err, driverRide) => {
    if (err) {
      // Handle error
      console.error('Error retrieving data:', err);
      res.status(500).json({ error: 'Error retrieving data' });
      return;
    } else {
      const start = `POINT(${startLocation})`;
      const end = `POINT(${endLocation})`;

      const insertSqlStmt = `INSERT INTO
                                RIDE_SHARE.RequestedRides
                                (PassengerID, RideID, StartAddress, DestinationAddress, Polyline, SeatsRequested)
                                VALUES (?, ?, ST_GeomFromText(?), ST_GeomFromText(?), ?, ?)`;

      const values = [riderId, selectedRideId, start, end, polyLine, numSeats]

      connection.query(insertSqlStmt, values, (err, results) => {
        if (err) {
          console.log("Error while inserting into RequestedRides table");
          return console.error(err.message);
        }
      });

      // send the notification to the driver
      const driverID = driverRide[0].DriverID;

      const notifData = {
          offeredRideId: selectedRideId,
          requestedPassengerId: riderId
      };

      sendRideRequestToDriver(driverID, notifData);
      res.status(200).json({status: "success"});
    }
  });
}

const getRideDetails = async (req, res) => {

};

const confirmRide = async (req, res) => {
  console.log("Recieved API request for Confirm Ride", req.body);
    const { confirmed, offeredRideID, requestedPassengerID } = req.body;
    if (confirmed) {
        const query = `
            INSERT INTO RIDE_SHARE.Confirmed_Rides (PassengerID, StartAddress, DestinationAddress, DriverRideID, TimeOfJourneyStart, Polyline)
            SELECT Req.PassengerID, Req.StartAddress, Req.DestinationAddress, ?, Off.TimeOfJourneyStart, Req.Polyline
            FROM RIDE_SHARE.RequestedRides Req
            JOIN RIDE_SHARE.OfferedRides Off ON Req.RideID = Off.RideID
            WHERE Req.PassengerID = ?;
        `;

        connection.query(query, [offeredRideID, requestedPassengerID, offeredRideID], (error, results) => {
            if (error) {
                console.error("Database error while moving requested ride to confirmed ride: ", error);
            } else {
                // Fetch the newly generated RideID
                const insertedRideID = results.insertId;

                // send the notification to requestedPassengerID that the ride has been confirmed
                // and send the ride id of the entry from Confirmed_Rides table
                  const notifData = {
                      offeredRideId: offeredRideID,
                      confirmedRideId: insertedRideID
                  };

                  sendRideConfirmationToRider(requestedPassengerID, notifData);
            }
        });
    } else {
        const deleteQuery = `
            DELETE FROM RIDE_SHARE.RequestedRides
            WHERE PassengerID = ? AND RideID = ?;
        `;

        connection.query(deleteQuery, [requestedPassengerID, offeredRideID], (error, results) => {
            if (error) {
                console.error("Database error while deleting entry from RequestedRides: ", error);
            } else {
                // send the notification to requestedPassengerID that the request was denied
                  const notifData = {
                      offeredRideId: offeredRideID,
                  };

                  sendRideRejectionToRider(requestedPassengerID, notifData);
            }
        });
    }
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

const getRequestedRide = async (req, res) => {
  const { offeredRideId, requestedPassengerId } = req.params;

  console.log("Received API request from driver to fetch the details of the requested ride");

  const query = `
    SELECT
      u.Name AS DriverName,
      ST_X(o.StartAddress) AS DriverStartLat,
      ST_Y(o.StartAddress) AS DriverStartLng,
      ST_X(o.DestinationAddress) AS DriverEndLat,
      ST_Y(o.DestinationAddress) AS DriverEndLng,
      o.SeatsAvailable,
      DATE_FORMAT(o.TimeOfJourneyStart, '%Y-%m-%dT%H:%i:%sZ') AS TimeOfJourneyStart,
      o.Polyline,
      u2.Name AS RiderName,
      ST_X(r.StartAddress) AS RiderStartLat,
      ST_Y(r.StartAddress) AS RiderStartLng,
      ST_X(r.DestinationAddress) AS RiderEndLat,
      ST_Y(r.DestinationAddress) AS RiderEndLng,
      r.SeatsRequested
    FROM
      RIDE_SHARE.Offered_Rides o
    LEFT JOIN
      RIDE_SHARE.RequestedRides r ON o.RideID = r.RideID
    LEFT JOIN
      RIDE_SHARE.Users u ON o.DriverID = u.UserID
    LEFT JOIN
      RIDE_SHARE.Users u2 ON r.PassengerID = u2.UserID
    WHERE
      o.RideID = ? AND r.PassengerID = ?;
  `;

  connection.query(query, [offeredRideId, requestedPassengerId], (err, results) => {
    if (err) {
      console.error(err);
      res.status(500).json({ error: 'Database query error' });
      return;
    }
    if (results.length > 0) {
      const result = results[0];
      const response = {
        DriverName: result.DriverName,
        DriverStartLat: result.DriverStartLat,
        DriverStartLng: result.DriverStartLng,
        DriverEndLat: result.DriverEndLat,
        DriverEndLng: result.DriverEndLng,
        SeatsAvailable: result.SeatsAvailable,
        TimeOfJourneyStart: moment(result.TimeOfJourneyStart).format('MMMM D, YYYY h:mm A'),
        Polyline: result.Polyline,
        RiderName: result.RiderName,
        RiderStartLat: result.RiderStartLat,
        RiderStartLng: result.RiderStartLng,
        RiderEndLat: result.RiderEndLat,
        RiderEndLng: result.RiderEndLng,
        SeatsRequested: result.SeatsRequested
      };
      res.json(response);
    } else {
      res.status(404).json({ error: 'Ride not found' });
    }
  });
};


module.exports = {
  signUpUser,
  loginUser,
  updateFcmToken,
  getUserDetails,
  modifyUserDetails,
  submitRide,
  findRides,
  requestRide,
  getRideDetails,
  confirmRide,
  riderCancelled,
  driverCancelled,
  driverActiveRides,
  passengerActiveRides,
  viewPassengers,
  getRequestedRide
};
