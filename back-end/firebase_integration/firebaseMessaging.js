const firebase = require('firebase-admin');
const serviceAccount = require('./rideshare-uci-firebase-adminsdk-78av6-45adc6272a.json')

firebase.initializeApp({
  credential: firebase.credential.cert(serviceAccount)
});

function sendRideRequestToDriver(token, data) {
  const message = {
    token: token,
    notification: {
      title: 'Please confirm ride request',
      body: 'A user has requested to hop on your ride, please confirm!!'
    },
    data: {
      offeredRideId: data.offeredRideId,
      requestedRideId: data.requestedRideId,
    }
  };

  return firebase.messaging().send(message)
}

function sendRideConfirmationToRider(token, data) {
  const message = {
    token: token,
    notification: {
      title: 'Ride confirmed',
      body: 'The driver has confirmed your ride!!'
    },
    data: {
      offeredRideId: data.offeredRideId,
      requestedRideId: data.requestedRideId,
    }
  };

  return firebase.messaging().send(message)
}

function sendRideRejectionToRider(token, data) {
  const message = {
    token: token,
    notification: {
      title: 'Coudn\'t confirm ride',
      body: 'The driver denied your ride request :('
    },
    data: {
      offeredRideId: data.offeredRideId,
      requestedRideId: data.requestedRideId,
    }
  };

  return firebase.messaging().send(message)
}

module.exports = {sendRideRequestToDriver, sendRideConfirmationToRider, sendRideRejectionToRider};
