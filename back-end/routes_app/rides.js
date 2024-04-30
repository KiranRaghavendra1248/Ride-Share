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
} = require("../controllers/rides");

// We can use chaining if reqd, see examples below
// Have defined basic ones, add api points as required
router.route("/login").post(loginUser);
router.route("/signup").post(signUpUser);
router.route("/:userID").post(getUserDetails);
router.route("/:userID").patch(modifyUserDetails);

router.route("/:userID/findrides").post(findRides);
router.route("/:userID/submitrides").post(submitRide);
router.route("/:userID/:rideID").post(getRideDetails).post(confirmRide);

module.exports = router;
