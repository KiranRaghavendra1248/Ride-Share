const firebase = require('firebase-admin');
const serviceAccount = require('./rideshare-uci-firebase-adminsdk-78av6-45adc6272a.json')

const { retrieveData, connection } = require("../db/connection");

firebase.initializeApp({
  credential: firebase.credential.cert(serviceAccount)
});

const notifTypeRideReq = "RideRequest";
const notifTypeRideConfirm = "RideConfirmation";
const notifTypeRideReject = "RideRejection";
const notifTypeRidePassengerCancel = "PassengerCancel";

function getToken(userID) {
  const query = 'SELECT FCMToken FROM RIDE_SHARE.Users WHERE UserID = ?';
  return new Promise((resolve, reject) => {
    connection.query(query, [userID], (error, results) => {
      if (error) {
        return reject(error);
      }
      if (results.length > 0) {
        return resolve(results[0].FCMToken);
      } else {
        return reject(new Error('No user found with the provided UserID'));
      }
    });
  });
}

async function sendRideRequestToDriver(userID, data) {
  try {
    const token = await getToken(userID);
    const message = {
      token: token,
      notification: {
        title: 'Please confirm ride request',
        body: 'A user has requested to hop on your ride, please confirm!!'
      },
      data: {
        type: notifTypeRideReq,
        offeredRideId: data.offeredRideId.toString(),
        requestedPassengerId: data.requestedPassengerId.toString(),
      }
    };

    const response = await firebase.messaging().send(message);
    console.log('Notification sent:', response);
  } catch (error) {
    console.error("Error while trying to fetch FCM token for user: ", userID, error);
  }
}

async function sendRideConfirmationToRider(userID, data) {
  try {
    const token = await getToken(userID);
    const message = {
      token: token,
      notification: {
        title: 'Ride confirmed',
        body: 'The driver has confirmed your ride!!'
      },
      data: {
        type: notifTypeRideConfirm,
        offeredRideId: data.offeredRideId.toString(),
        confirmedRideId: data.confirmedRideId.toString(),
      }
    };

    const response = await firebase.messaging().send(message);
    console.log('Confirmation notification sent:', response);
    return response; // Optionally return the response if needed elsewhere
  } catch (error) {
    console.error("Error while trying to fetch FCM token for user: ", userID, error);
  }
}

async function sendRideRejectionToRider(userID, data) {
  try {
    const token = await getToken(userID);
    const message = {
      token: token,
      notification: {
        title: 'Couldn\'t confirm ride',
        body: 'The driver denied your ride request :('
      },
      data: {
        type: notifTypeRideReject, 
        offeredRideId: data.offeredRideId.toString(),
      }
    };

    const response = await firebase.messaging().send(message);
    console.log('Rejection notification sent:', response);
  } catch (error) {
    console.error("Error while trying to fetch FCM token for user: ", userID, error);
  }
}

async function sendCancellationNotificationtoDriver(userID, data) {
  try {
    const token = await getToken(userID);
    const message = {
      token: token,
      notification: {
        title: 'A passenger chose to cancel a ride',
        body: 'View current passengers in Active Rides'
      },
      data: {
        type: notifTypeRidePassengerCancel
      }
    };

    const response = await firebase.messaging().send(message);
    console.log('Rejection notification sent:', response);
  } catch (error) {
    console.error("Error while trying to fetch FCM token for user: ", userID, error);
  }
}


module.exports = {sendRideRequestToDriver, sendRideConfirmationToRider, sendRideRejectionToRider, sendCancellationNotificationtoDriver};
