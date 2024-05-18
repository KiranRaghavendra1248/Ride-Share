import 'package:flutter/material.dart';

class PastRidesScreen extends StatefulWidget {
  const PastRidesScreen({Key? key}) : super(key: key);

  @override
  _PastRidesScreenState createState() => _PastRidesScreenState();
}

class _PastRidesScreenState extends State<PastRidesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<String> ridesOffered = [
    'LAX - SNA',
    'Humanities Hall - Parkwest',
    'Parkwest - LAX',
    'Spectrum Center - NewPort Beach',
    'Parkwest - Spectrum Center'
  ];

  List<String> ridesBooked = [
    'SNA - UC Irvine',
    'Laguna Beach - Parkview Ln',
    'Parkview Ln - Laguna Beach',
    'DBH - Rancho San',
    'Rancho San - DBH'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Past Rides'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Rides Offered'),
            Tab(text: 'Rides Booked'),
          ],
          indicatorColor: Colors.deepPurple,
            labelColor: Colors.deepPurple,// Change the color of the highlighted tabs
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Rides Offered Tab
          ListView.builder(
            itemCount: ridesOffered.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(ridesOffered[index]),
                onTap: () {
                  _showRideDetails(context, ridesOffered[index]);
                },
              );
            },
          ),
          // Rides Booked Tab
          ListView.builder(
            itemCount: ridesBooked.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(ridesBooked[index]),
                onTap: () {
                  _showRideDetails(context, ridesBooked[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showRideDetails(BuildContext context, String rideTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ride Details'),
          content: Text('Details for the ride: $rideTitle'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
