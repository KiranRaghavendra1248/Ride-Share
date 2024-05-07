const firebase = require('firebase-admin');
const serviceAccount = require('./rideshare-uci-firebase-adminsdk-78av6-45adc6272a.json')

const { retrieveData, connection } = require("../db/connection");

firebase.initializeApp({
  credential: firebase.credential.cert(serviceAccount)
});

const notifTypeRideReq = "RideRequest";
const notifTypeRideConfirm = "RideConfirmation";
const notifTypeRideReject = "RideRejection";

function getToken(userID, callback) {
    const query = 'SELECT FCMToken FROM RIDE_SHARE.Users WHERE UserID = ?';

    connection.query(query, [userID], (error, results) => {
        if (error) {
            return callback(error, null);
        }
        if (results.length > 0) {
            return callback(null, results[0].FCMToken);
        } else {
            return callback(new Error('No user found with the provided UserID'), null);
        }
    });
}

function sendRideRequestToDriver(userID, data) {
  getToken(userID, (error, token) => {
    if (error) {
      console.log("Error while trying to fetch FCM token for user: ", userID);
      throw new Error(error.message);
    }
    const message = {
      token: token,
      notification: {
        title: 'Please confirm ride request',
        body: 'A user has requested to hop on your ride, please confirm!!'
      },
      data: {
        type: notifTypeRideReq,
        offeredRideId: data.offeredRideId,
        requestedPassengerId: data.requestePassengerId,
      }
    };

    return firebase.messaging().send(message)
  });
}

function sendRideConfirmationToRider(userID, data) {
  getToken(userID, (error, token) => {
    if (error) {
      console.log("Error while trying to fetch FCM token for user: ", userID);
      throw new Error(error.message);
    }
    const message = {
      token: token,
      notification: {
        title: 'Ride confirmed',
        body: 'The driver has confirmed your ride!!'
      },
      data: {
        type: notifTypeRideConfirm,
        offeredRideId: data.offeredRideId,
        confirmedRideId: data.confirmedRideId,
      }
    };

    return firebase.messaging().send(message)
  });
}

function sendRideRejectionToRider(userID, data) {
  getToken(userID, (error, token) => {
    if (error) {
      console.log("Error while trying to fetch FCM token for user: ", userID);
      throw new Error(error.message);
    }
      const message = {
        token: token,
        notification: {
          title: 'Coudn\'t confirm ride',
          body: 'The driver denied your ride request :('
        },
        data: {
          type: notifTypeRideReject,
          offeredRideId: data.offeredRideId,
        }
      };

      return firebase.messaging().send(message)
  });
}

module.exports = {sendRideRequestToDriver, sendRideConfirmationToRider, sendRideRejectionToRider};
