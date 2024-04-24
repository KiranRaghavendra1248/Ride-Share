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
router.route("/login").get(loginUser);
router.route("/signup").get(signUpUser);
router.route("/:userID").get(getUserDetails);
router.route("/:userID").patch(modifyUserDetails);

router.route("/:userID/rides").get(findRides).post(submitRide);
router.route("/:userID/:rideID").get(getRideDetails).post(confirmRide);

module.exports = router;
