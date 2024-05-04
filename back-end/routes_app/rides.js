const express = require("express");
const router = express.Router();

const {
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
} = require("../controllers/rides");

router.route("/login").post(loginUser);
router.route("/signup").post(signUpUser);
router.route("/:userID").post(getUserDetails);
router.route("/:userID").patch(modifyUserDetails);

router.route("/:userID/findrides").post(findRides)
router.route("/:userID/submitrides").post(submitRide);
router.route("/:userID/:rideID/info").post(getRideDetails)
router.route("/:userID/:rideID/confirm").post(confirmRide);

router.route("/:userID/:rideID/ridercancel").post(riderCancelled)
router.route("/:userID/:rideID/drivercancel").post(driverCancelled);

module.exports = router;
