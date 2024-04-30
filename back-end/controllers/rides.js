const { retrieveData } = require("../db/connection");
const { buildQueryForFindRide,buildQueryForSubmitRide, convertTimeToDateTime, convertCoordinates } = require("./utils");
const { execute } = require('../db/connection');

const signUpUser = async (req, res) => {
  // Sample query
  // INSERT INTO RIDE_SHARE.Users (UserID, FirstName, LastName, EmailID, CountryCode, PhoneNumber) VALUES (456, 'John', 'Doe', 'john@example.com', '+1', '1234567890');
};

const loginUser = async (req, res) => {

};

const getUserDetails = async (req, res) => {

};

const modifyUserDetails = async (req, res) => {

};


const submitRide = async (req, res) => {
  const { RideID, Date, start_latitude, start_longitude, destination_latitude, destination_longitude, startTime, numSeats, polyline, userID } = req.body;
  const DriverID = userID; // Use userID as DriverID
  console.log("Request Body:", req.body);

  const dateTime = convertTimeToDateTime(startTime, Date);

  // Correctly construct the POINT from parameters and ensure the order is (longitude, latitude)
  const startCoords = `POINT(${start_longitude} ${start_latitude})`;
  const destCoords = `POINT(${destination_longitude} ${destination_latitude})`;
  console.log(startCoords)

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
      res.status(200).json({ message: "Ride submitted successfully", data: results });
  } catch (error) {
      console.error('Failed to submit ride:', error);
      res.status(500).json({ error: 'Database operation failed', details: error });
  }
};


const findRides = async (req, res) => {
  const startTime = convertTimeToDateTime(req.body.startTime);
  const endTime = convertTimeToDateTime(req.body.endTime);
  const startLocation = convertCoordinates(req.body.start);
  const endLocation = convertCoordinates(req.body.destination);
  const numSeats = req.body.numSeats;

  query = buildQueryForFindRide(startTime, endTime, startLocation, endLocation, numSeats);
  result = retrieveData(query, (err, results) => {
    if (err) {
      // Handle error
      console.error('Error retrieving data:', err);
      res.status(500).json({ error: 'Error retrieving data' });
      return;
    }
    // Send the results back to the client
    console.log(results);
    res.status(200).json(results);
  });
};

const getRideDetails = async (req, res) => {

};

const confirmRide = async (req, res) => {

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
};
