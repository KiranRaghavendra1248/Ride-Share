const buildQueryForFindRide = (startTime, endTime, startLocation, endLocation, numSeats) => {

    const query =  `SELECT *,
                        ST_Distance_Sphere(StartAddress, ST_GeomFromText('POINT(${startLocation})')) +
                        ST_Distance_Sphere(DestinationAddress, ST_GeomFromText('POINT(${endLocation})')) AS total_distance
                    FROM RIDE_SHARE.Offered_Rides
                    WHERE TimeOfJourneyStart BETWEEN '${startTime}' AND '${endTime}'
                        AND CAST('${numSeats}' AS UNSIGNED) <= SeatsAvailable
                    ORDER BY total_distance ASC
                    LIMIT 5;`;
            
    return query;
}

const buildQueryForSubmitRide = (DriverID, StartAddress, DestinationAddress, SeatsAvailable, TimeOfJourneyStart, Polyline) => {
  const query = `INSERT INTO RIDE_SHARE.Offered_Rides
                 (DriverID, StartAddress, DestinationAddress, SeatsAvailable, TimeOfJourneyStart, Polyline)
                 VALUES (?, ST_GeomFromText(?), ST_GeomFromText(?), ?, ?, ?);`;
  return query;
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
  

  const convertCoordinates = (originalCoordinates) => {
    const [latitude, longitude] = originalCoordinates.split(',');
    const convertedCoordinates = `${longitude} ${latitude}`;
    return convertedCoordinates;
}


module.exports = {buildQueryForFindRide,buildQueryForSubmitRide, convertTimeToDateTime, convertCoordinates}