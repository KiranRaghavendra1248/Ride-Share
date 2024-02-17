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
      <li> Home page displays Uber/Lyft-like map from Google Maps API</li>
      <li> Fields - Start, Destination, Time Range(drop down), Driver or Passenger(drop down) </li>
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
</ol>

## Requirements (Financial)
<ul>
  <li> Choosing appropriate database(analyse functional requirements from database and finalise) </li>
  <li> Google Map APIs </li>
  <li> Payment Gateway APIs (Paytm, Stripe etc)</li>
  <li> Deployment</li>
</ul> 

