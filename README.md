# Ride-Share
## Functional Features 
<ol>
  <li>
  Register/Login Page
    <ul>
      <li> Register/Login option - check with database - Success/Fail</li>
      <li> OAuth Option </li>
    </ul>
  </li>
  <li>
  Home Page
    <ul>
      <li> 2 modes - driving or looking for a ride</li>
      <li> Home page displays Uber/Lyft-like map from Google Maps API</li>
      <li> Fields - Start, Destination, Time Range(drop down), Number of seats</li>
      <li> Buttons - Find ride button</li>
    </ul>
  </li>
  <li>
  Driver clicks on Find Ride
    <ul>
      <li> Page that says, push notification submitted(stores entry to database)</li>
      <li> Should give push notification when co-passenger selects this driver</li>
      <li> Option to Accept/Decline ride</li>
    </ul>
  </li>
   <li>
  Passenger clicks on = Find Ride
    <ul>
      <li> Page that retrieves rides with matching sources and destination(retrieves entries from database)</li>
      <li> Option to select driver - this should give push notification to selected driver</li>
      <li> If no entries found matching requirements - page that says nothing was found</li>
    </ul>
  </li>
  <li>
  Sliding Menu Bar - Like Lyft
    <ul>
      <li> Button when clicked brings up sliding menu bar</li>
      <li> Options - Home, Account, Logout, Ride History</li>
    </ul>
  </li>
  <li>
  Payment Gateway
    <ul>
      <li> After a ride or just before finalizing the ride</li>
      <li> Redirect to payment gateway - Success/Fail</li>
    </ul>
  </li>
  <li>
  Pre Schedule Rides
    <ul>
      <li> User can select rides for future</li>
      <li> Driver can put down rides for future</li>
    </ul>
  </li>
  <li>
  Chat between Driver and Rider
    <ul>
      <li> Chat feature</li>
    </ul>
  </li>
  <li>
  Number of seats
    <ul>
      <li> Driver has to select the number of seats available while submitting request</li>
      <li> Number of vacancies gets reduced when a user books some seats in that car </li>
    </ul>
  </li>
</ol>

## Requirements (Financial)
<ul>
  <li> Choosing appropriate database(analyse functional requirements from database and finalise) </li>
  <li> Google Map APIs </li>
  <li> Payment Gateway APIs (Paytm, Stripe etc)</li>
  <li> Deployment</li>
</ul> 

