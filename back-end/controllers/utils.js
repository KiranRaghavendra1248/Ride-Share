const fs = require('fs');

const buildQueryForFindRide = (startTime, endTime, startLocation, endLocation, numSeats, threshold, passengerID) => {
  // AND DriverID != ${passengerID} add this in line 14 when deploying
  const query = `SELECT *
                    FROM (
                        SELECT RideID, DriverID, StartAddress, DestinationAddress, SeatsAvailable, 
                                DATE_FORMAT(TimeOfJourneyStart, '%Y-%m-%d %H:%i:%s') AS JourneyStart,
                                ST_Distance_Sphere(StartAddress, ST_GeomFromText('POINT(${startLocation})')) +
                                ST_Distance_Sphere(DestinationAddress, ST_GeomFromText('POINT(${endLocation})')) AS distance_in_meters
                        FROM RIDE_SHARE.Offered_Rides
                        WHERE TimeOfJourneyStart BETWEEN '${startTime}' AND '${endTime}'
                            AND CAST('${numSeats}' AS UNSIGNED) <= SeatsAvailable
                    ) AS subquery
                    WHERE distance_in_meters < ${threshold}
                    ORDER BY distance_in_meters ASC
                    LIMIT 5;`;

  return query;
}

const buildQueryRetrieveUserDetails = (userIDs) => {
    const userIDString = userIDs.join(', ');

    // Construct the SQL query with the dynamic IN clause
    const query = `SELECT *
                    FROM RIDE_SHARE.Users
                    WHERE UserID IN (${userIDString});`;

    return query;
}

const buildQueryRetrieveUserDetailswithDriverRideID = (driverRideIDs) => {
  const driverRideIDString = driverRideIDs.join(", ");

  const query = `SELECT Off.RideID AS DriverRideID, U.UserID AS UserID, U.Name AS Name, U.EmailID AS EmailID, U.Phone AS Phone
                  FROM RIDE_SHARE.Users U
                  JOIN RIDE_SHARE.Offered_Rides Off ON Off.DriverID = U.UserID
                  WHERE Off.RideID in (${driverRideIDString})`;
  return query;
}
const buildQueryRetrieveConfirmedRide = (rideID) => {
  const query = `SELECT *
                    FROM RIDE_SHARE.Confirmed_Rides
                    WHERE RideID = ${rideID};`
  return query;
}

const buildQueryForSubmitRide = (DriverID, StartAddress, DestinationAddress, SeatsAvailable, TimeOfJourneyStart, Polyline) => {
    const query = `INSERT INTO RIDE_SHARE.Offered_Rides
                   (DriverID, StartAddress, DestinationAddress, SeatsAvailable, TimeOfJourneyStart, Polyline)
                   VALUES (?, ST_GeomFromText(?), ST_GeomFromText(?), ?, ?, ?);`;
    return query;
  }

const buildQueryRetrieveOfferedRide = (rideID) => {
  const query = `SELECT *
                    FROM RIDE_SHARE.Offered_Rides
                    WHERE RideID = ${rideID};`
  return query;
}

const buildQueryDeleteConfirmedRide = (rideID) => {
  const query = `DELETE 
                    FROM RIDE_SHARE.Confirmed_Rides 
                    WHERE RideID = ${rideID};`;
  return query;
}

const buildQueryForPassengerActiveRides = (userID) => {
  const query = `SELECT 
  RideID, StartAddress, DestinationAddress, DriverRideID, DATE_FORMAT(TimeOfJourneyStart, '%Y-%m-%d %H:%i:%s') AS TimeOfJourneyStart
  FROM RIDE_SHARE.Confirmed_Rides WHERE PassengerID = ${userID} AND TimeOfJourneyStart > NOW();`
  return query;
}

// Function to fetch the last user ID from the JSON file
const getLastUserID = () => {
  try {
    const userData = require(__dirname + '/id-tracker.json');
    return userData['lastUserID'];
  } catch (error) {
    console.error('Error reading user IDs file:', error);
    return null;
  }
}

// Function to validate password constraints
const validatePassword = (password) => {
  // Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, and one digit
  const passwordRegex = /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z]{8,}$/;
  return passwordRegex.test(password);
}

// Function to update the last user ID in the JSON file
const updateLastUserID = (newUserID) => {
  try {
    const userData = require(__dirname + '/id-tracker.json');
    userData['lastUserID'] = newUserID;
    fs.writeFileSync(__dirname + '/id-tracker.json', JSON.stringify(userData));
    return true;
  } catch (error) {
    console.error('Error updating user IDs file:', error);
    return false;
  }
}

const updateLastDriverRideID = (newDriverRideID) => {
    try {
      const userData = require(__dirname + '/id-tracker.json');
      userData['lastDriverRideID'] = newDriverRideID;
      fs.writeFileSync(__dirname + '/id-tracker.json', JSON.stringify(userData));
      return true;
    } catch (error) {
      console.error('Error updating user IDs file:', error);
      return false;
    }
  }

const convertTimeToDateTime = (timeString) => {
  // Get today's date
  const today = new Date();

  // Split the time string into hours, minutes, and AM/PM parts
  const [time, period] = timeString.split(' ');
  const [hours, minutes] = time.split(':').map(Number);

  // Convert hours to 24-hour format if needed
  let hours24 = hours;
  if (period === 'PM' && hours !== 12) {
    hours24 += 12;
  } else if (period === 'AM' && hours === 12) {
    hours24 = 0;
  }

  // Set the time from the provided string to today's date
  today.setHours(hours24, minutes, 0, 0);

  // Extract the components of the date
  const year = today.getFullYear();
  const month = String(today.getMonth() + 1).padStart(2, '0');
  const day = String(today.getDate()).padStart(2, '0');
  const hoursFormatted = String(today.getHours()).padStart(2, '0');
  const minutesFormatted = String(today.getMinutes()).padStart(2, '0');
  const seconds = '00'; // Set seconds to '00'

  // Format the date and time components into the desired format
  const formattedDateTime = `${year}-${month}-${day} ${hoursFormatted}:${minutesFormatted}:${seconds}`;

  return formattedDateTime;
};

const buildQueryDeleteOfferedRide = (rideID) => {
  const query = `DELETE 
                    FROM RIDE_SHARE.Offered_Rides 
                    WHERE RideID = ${rideID};`;
  return query;
}



const convertTimeToDateTime_Suraj = (timeString, date) => {
  // Assuming the date is passed in as a UTC string
  const providedDate = new Date(date);

  // Log the provided UTC date for debugging
  console.log('Provided UTC date:', providedDate.toISOString());

  // Split the time string into hours, minutes, and AM/PM parts
  const [time, period] = timeString.split(' ');
  const [hours, minutes] = time.split(':').map(Number);

  // Convert hours to 24-hour format if needed
  let hours24 = hours;
  if (period === 'PM' && hours !== 12) {
    hours24 += 12;
  } else if (period === 'AM' && hours === 12) {
    hours24 = 0;
  }

  // Set the time from the provided string to the provided date using UTC methods
  providedDate.setUTCHours(hours24, minutes, 0, 0);

  // Extract the components of the date using UTC methods
  const year = providedDate.getUTCFullYear();
  const month = String(providedDate.getUTCMonth() + 1).padStart(2, '0');
  const day = String(providedDate.getUTCDate()).padStart(2, '0');
  const hoursFormatted = String(providedDate.getUTCHours()).padStart(2, '0');
  const minutesFormatted = String(providedDate.getUTCMinutes()).padStart(2, '0');
  const seconds = '00'; // Set seconds to '00'

  // Format the date and time components into the desired format
  const formattedDateTime = `${year}-${month}-${day} ${hoursFormatted}:${minutesFormatted}:${seconds}`;

  return formattedDateTime;
};



const convertCoordinates = (originalCoordinates) => {
  const [latitude, longitude] = originalCoordinates.split(',');
  const convertedCoordinates = `${longitude} ${latitude}`;
  return convertedCoordinates;
}

const createBackendFiles = () => {
  const filepath = __dirname + '/id-tracker.json';
  const defaultValue = {
    lastUserID: 0,
    lastDriverRideID: 0,
    lastPassengerRideID: 0
  };

  // Check if the file exists

  fs.access(filepath, fs.constants.F_OK, (err) => {
    if (err) {
      // File doesn't exist, create it
      fs.writeFileSync(filepath, JSON.stringify(defaultValue), (err) => {
        if (err) throw err;
        console.log(`${filepath} created with initial value.`);
      });
    } else {
      console.log(`${filepath} already exists.`);
    }
  });

}


module.exports = { buildQueryForFindRide,
                   convertTimeToDateTime,
                   convertTimeToDateTime_Suraj,
                   convertCoordinates,
                   validatePassword,
                   getLastUserID,
                   updateLastUserID,
                   createBackendFiles,
                   buildQueryRetrieveConfirmedRide,
                   buildQueryRetrieveOfferedRide,
                   buildQueryDeleteConfirmedRide,
                   buildQueryForSubmitRide,
                   updateLastDriverRideID,
                   buildQueryRetrieveUserDetails,
                   buildQueryForPassengerActiveRides,
                   buildQueryRetrieveUserDetailswithDriverRideID,
                   buildQueryDeleteOfferedRide
                 }
