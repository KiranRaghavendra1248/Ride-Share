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
  driverList,
  viewPassengers
} = require("../controllers/rides");

router.route("/login").post(loginUser);
router.route("/register").post(signUpUser);
router.route("/updateFcmToken").post(updateFcmToken);
router.route("/:userID").post(getUserDetails);
router.route("/:userID").patch(modifyUserDetails);

// when rider wants to find available rides for the
// route he/she wants to travel
router.route("/:userID/findrides").post(findRides)

// when rider wants to request confirmation for a ride
router.route("/:userID/requestRide").post(requestRide);

// when driver wants to submit new ride offer
router.route("/:userID/submitrides").post(submitRide);
router.route("/:userID/:rideID/info").post(getRideDetails)
router.route("/:userID/:rideID/confirm").post(confirmRide);
router.route("/:userID/driverlist").post(driverList);
router.route("/:userID/viewpassengers").post(viewPassengers);

router.route("/:userID/:rideID/ridercancel").post(riderCancelled);
router.route("/:userID/:rideID/drivercancel").post(driverCancelled);

module.exports = router;
