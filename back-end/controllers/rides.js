const { retrieveData, connection, execute } = require("../db/connection");
const { sendRideRequestToDriver, sendRideConfirmationToRider, sendRideRejectionToRider, sendCancellationNotificationtoDriver, sendCancellationNotificationtoRider } = require("../firebase_integration/firebaseMessaging");


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
  buildQueryRetrieveConfirmedRide,
  buildQueryRetrieveUserDetails,
  buildQueryForPassengerActiveRides,
  buildQueryRetrieveUserDetailswithDriverRideID,
  buildQueryDeleteOfferedRide,
  buildQueryDeleteConfirmedRide
} = require("./utils");

const bcrypt = require('bcrypt');
const validator = require('validator');
const fs = require('fs');
const moment = require('moment');
const { json } = require("body-parser");


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
        return res.status(200).json({'message': "success"});
    });

}

const getUserDetails = async (req, res) => {
  console.log("Recieved API request for Get User Details");

  const userId = req.params.userID; // Retrieving userId from URL parameters

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

  retrieveData(query, (err, results) => {
    if (err) {
      console.error("Error retrieving Driver Active Rides");
      res.status(500).json({ error: 'Error retrieving data' });
      return;
    }
    if (0 == results.length) {
      response = {
        "message": "No rides available"
      }
      return res.status(200).json([response]);
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
    if (0 == results.length) {
      response = {
        "message": "No rides available"
      }
      return res.status(200).json([response]);
    }
    driverRideIDs = [];
    for (let i = 0; i < results.length; i++) {
      driverRideIDs.push(results[i]['DriverRideID']);
    }
    getUserDetailsQuery = buildQueryRetrieveUserDetailswithDriverRideID(driverRideIDs);
    retrieveData(getUserDetailsQuery, (err1, results1) => {
      if (err1) {
        console.error('Error retrieving data:', err1);
        res.status(500).json({ error: 'Error retrieving data' });
        return;
      }
      for (let i = 0; i < results.length; i++) {
        for (let j = 0; j < results1.length; j++) {
          if (results[i]['DriverRideID'] == results1[j]['DriverRideID']) {
            results[i]['driverDetails'] = results1[j];
          }
        }
      }
      console.log(results);
      return res.status(200).json(results);
    })
  })
}

const viewPassengers = async (req, res) => {
  console.log("Received API request for View Passengers");
  const { userID, RideID } = req.body;

  if (!userID) {
    return res.status(400).json({
      message: "UserID is required"
    });
  }

  const query = "SELECT PassengerID FROM RIDE_SHARE.Confirmed_Rides WHERE DriverRideID = ?;";
  try {
    const results = await execute(query, [RideID]);
    console.log("Query results:", results);

    if (results.length === 0) {
      return res.status(404).json({ message: "No passengers found" });
    }

    const passengerIDs = results.map(row => row.PassengerID);
    console.log("Passenger IDs:", passengerIDs); // Log to see the passenger IDs

    if (passengerIDs.length > 0) {
      // SQL IN clause handling
      const placeholders = passengerIDs.map(() => '?').join(',');
      const users_query = `SELECT Name, Phone FROM RIDE_SHARE.Users WHERE UserID IN (${placeholders});`;
      const final_res = await execute(users_query, passengerIDs);
      console.log("Final results:", final_res); // Log final results

      if (final_res.length > 0) {
        res.status(200).json(final_res);
      } else {
        res.status(404).json({ message: "No user details found for provided IDs" });
      }
    } else {
      res.status(404).json({ message: "No Passenger IDs found" });
    }
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ message: "Internal server error" });
  }
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
    console.log(results, results.length);
    userIDs = [];
    for (let i = 0; i < results.length; i++) {
      userIDs.push(results[i]['DriverID']);
    }
    if (0 == results.length) {
      response = {
        "message": "No rides available"
      }
      return res.status(200).json([response]);
    }
    getUserDetailsQuery = buildQueryRetrieveUserDetails(userIDs);
    retrieveData(getUserDetailsQuery, (err, userDetails) => {
      if (err) {
        // Handle error
        console.error('Error retrieving data:', err);
        res.status(500).json({ error: 'Error retrieving data' });
        return;
      }
      for (let i = 0; i < results.length; i++) {
        results[i]['distance_in_meters'] = parseInt(results[i]['distance_in_meters']);
        for (let j = 0; j < userDetails.length; j++) {
          if (results[i]['DriverID'] == userDetails[j]['UserID']) {
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
      res.status(200).json({ status: "success" });
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
            JOIN RIDE_SHARE.Offered_Rides Off ON Req.RideID = Off.RideID
            WHERE Req.PassengerID = ? AND Off.RideID = ?;
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
    if (0 == passengerRide.length) {
      return res.status(200).json({ "message": "This ride does not exist anyway" });
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
      const driverID = driverRide[0].DriverID;
      // Remove entry from confirmed rides table
      deleteRideConfirmedRideTableQuery = buildQueryDeleteConfirmedRide(passengerrideID);
      console.log(deleteRideConfirmedRideTableQuery);
      try {
        execute(deleteRideConfirmedRideTableQuery);
        // Send push notification to Driver
        sendCancellationNotificationtoDriver(driverID,)
        res.status(200).json([{ "message": "Cancellation Successful" }]);
      }
      catch (err) {
        console.error(err);
        res.status(401).json([{ "message": "Cancellation Failed" }]);
      }
    });
  });
};

const driverCancelled = async (req, res) => {
  console.log("Received API request for Driver Side Ride Cancellation");
  const { RideID } = req.body;
  console.log(RideID);
  const query = "SELECT RideID, PassengerID FROM RIDE_SHARE.Confirmed_Rides WHERE DriverRideID = ?;";

  try {
    const results = await execute(query, [RideID]);
    console.log("Query results:", results);

    if (results.length === 0) {
      return res.status(404).json({ message: "No passengers found" });
    }

    const promises = results.map(async (result) => {
      const { RideID, PassengerID } = result;
      console.log(RideID);
      console.log(PassengerID);
      const deleteRideConfirmedRideTableQuery = buildQueryDeleteConfirmedRide(RideID);
      console.log(deleteRideConfirmedRideTableQuery);
      await execute(deleteRideConfirmedRideTableQuery);
      await sendCancellationNotificationtoRider(PassengerID);
      console.log(`Processed RideID: ${RideID} and PassengerID: ${PassengerID}`);
    });

    // Wait for all promises to complete
    await Promise.all(promises);

    const deleteOfferedRideTableQuery = buildQueryDeleteOfferedRide(RideID);
    console.log(deleteOfferedRideTableQuery);
    await execute(deleteOfferedRideTableQuery);
    res.status(200).json({ message: "All rides processed successfully" });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ message: "Internal server error" });
  }
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
}

const riderRideHistory = async (req, res) => {
  const riderId = req.params.userID; // Retrieving riderId from URL parameters

  // Check if riderId is provided
  if (!riderId) {
    return res.status(400).json({ success: false, message: 'Rider ID is required' });
  }

  // User exists, query to retrieve rider's ride history
  const rideHistorySql = `
  SELECT 
  RideID, StartAddress, DestinationAddress, DriverRideID, DATE_FORMAT(TimeOfJourneyStart, '%Y-%m-%d %H:%i:%s') AS TimeOfJourneyStart
  FROM RIDE_SHARE.Confirmed_Rides WHERE PassengerID = ${riderId} AND TimeOfJourneyStart < NOW();`;

  // Execute the query to get ride history
  connection.query(rideHistorySql, function (err, results) {
    if (err) {
      console.error('Error retrieving rider ride history:', err);
      return res.status(500).json({ success: false, message: 'Internal server error' });
    } else {
      if (results.length > 0) {
        driverRideIDs = [];
        for (let i = 0; i < results.length; i++) {
          driverRideIDs.push(results[i]['DriverRideID']);
        }
        getUserDetailsQuery = buildQueryRetrieveUserDetailswithDriverRideID(driverRideIDs);
        retrieveData(getUserDetailsQuery, (err1, results1) => {
          if (err1) {
            console.error('Error retrieving data:', err1);
            res.status(500).json({ error: 'Error retrieving data' });
            return;
          }
          for (let i = 0; i < results.length; i++) {
            for (let j = 0; j < results1.length; j++) {
              if (results[i]['DriverRideID'] == results1[j]['DriverRideID']) {
                results[i]['driverDetails'] = results1[j];
              }
            }
          }
          console.log(results);
          return res.status(200).json(results);
        })
      } else {
        // No ride history found for the rider
        return res.status(200).json({ success: true, message: 'No rides available' });
      }
    }
  });
}

const driverRideHistory = async (req, res) => {
  const driverId = req.params.userID; // Retrieving driverId from URL parameters

  // Check if driverId is provided
  if (!driverId) {
    return res.status(400).json({ success: false, message: 'Driver ID is required' });
  }

  const values = [driverId];

  // Using parameterized queries to prevent SQL injection
  const query = `SELECT 
  RideID, DriverID, StartAddress, DestinationAddress, SeatsAvailable, DATE_FORMAT(TimeOfJourneyStart, '%Y-%m-%d %H:%i:%s') AS JourneyStart 
  FROM RIDE_SHARE.Offered_Rides 
  WHERE DriverID = ${driverId} AND TimeOfJourneyStart < NOW();`;

  retrieveData(query, (err, results) => {
    if (err) {
      console.error("Error retrieving Driver Active Rides");
      res.status(500).json([{ error: 'Error retrieving data' }]);
      return;
    }
    if (0 == results.length) {
      response = {
        "message": "No rides available"
      }
      return res.status(200).json([response]);
    }
    console.log(results);
    return res.status(200).json(results);
  })

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
  getRequestedRide,
  riderRideHistory,
  driverRideHistory
};
