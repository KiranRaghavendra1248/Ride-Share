import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class RideListScreen extends StatelessWidget {
  final List<dynamic> rides;

  const RideListScreen({Key? key, required this.rides}) : super(key: key);

  Future<String> getAddressFromLatLong(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(longitude, latitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = "";
        if (place.street != null) {
          address += place.street!;
        }
        if (place.locality != null) {
          if (address.isNotEmpty) address += ", ";
          address += place.locality!;
        }
        return address;
      } else {
        print("No placemarks found for the given coordinates: Lat=$latitude, Long=$longitude");
        return "No address available";
      }
    } catch (e, stacktrace) {
      print("Failed to get address due to an error: $e");
      print("Stacktrace: $stacktrace");
      return "Failed to get address";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Rides'),
      ),
      body: ListView.builder(
        itemCount: rides.length,
        itemBuilder: (context, index) {
          var ride = rides[index];
          double startX = ride['StartAddress']['x']; // Longitude
          double startY = ride['StartAddress']['y']; // Latitude
          double destX = ride['DestinationAddress']['x']; // Longitude
          double destY = ride['DestinationAddress']['y']; // Latitude

          return FutureBuilder(
            future: Future.wait([
              getAddressFromLatLong(startX, startY),
              getAddressFromLatLong(destX, destY),
            ]),
            builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(10),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ride ID: ${ride['RideID']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Start Address: ${snapshot.data![0]}', style: TextStyle(fontSize: 14)),
                        Text('Destination Address: ${snapshot.data![1]}', style: TextStyle(fontSize: 14)),
                        Text('Journey Start: ${ride['JourneyStart']}', style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Logic to view passengers
                              },
                              child: const Text('Passengers'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirm'),
                                    content: const Text('Do you want to cancel this ride?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Implement cancellation logic here
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Yes'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text('Cancel Ride'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
