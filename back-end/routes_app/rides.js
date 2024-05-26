const express = require("express");
const router = express.Router();

const {
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
} = require("../controllers/rides");

router.route("/login").post(loginUser);
router.route("/register").post(signUpUser);
<<<<<<< HEAD
router.route("/updateFcmToken").post(updateFcmToken);
router.route("/:userID").post(getUserDetails);
router.route("/:userID").patch(modifyUserDetails);
=======
router.route("/:userID").get(getUserDetails).patch(modifyUserDetails);
>>>>>>> 067b949 (Get user details BE working)

// when rider wants to find available rides for the
// route he/she wants to travel
router.route("/:userID/findrides").post(findRides);

// when rider wants to request confirmation for a ride
router.route("/:userID/requestRide").post(requestRide);
router.route("/:userID/confirmRide").post(confirmRide);

// when driver wants to submit new ride offer
router.route("/:userID/submitrides").post(submitRide);
router.route("/:userID/:rideID/info").post(getRideDetails)
router.route("/:userID/:rideID/confirm").post(confirmRide);
router.route("/:userID/driveractiverides").post(driverActiveRides);
router.route("/:userID/passengeractiverides").post(passengerActiveRides);
router.route("/:userID/driverviewpassengers").post(viewPassengers);
router.route("/:userID/:rideID/info").post(getRideDetails);

router.route("/:userID/:rideID/ridercancel").post(riderCancelled);
router.route("/:userID/:rideID/drivercancel").post(driverCancelled);

// get details of ride request (used by the driver frontend)
router.route("/getRequestedRide/:offeredRideId/:requestedPassengerId").get(getRequestedRide);

module.exports = router;
