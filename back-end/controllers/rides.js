const { retrieveData, runQuery } = require("../db/connection");
const { 
  buildQueryForFindRide, 
  convertTimeToDateTime, 
  convertCoordinates, 
  buildQueryRetrieveConfirmedRide, 
  buildQueryRetrieveOfferedRide,
  buildQueryDeleteConfirmedRide
} = require("./utils");

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
      try{
        runQuery(deleteRideConfirmedRideTableQuery);
      }
      catch(err){
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
