import 'package:flutter/material.dart';
import 'package:dawarich/ui/widgets/appbar.dart';
import 'package:dawarich/ui/widgets/drawer.dart';
import 'package:geolocator/geolocator.dart';

class TrackerPage extends StatefulWidget {

  const TrackerPage({super.key});

  @override
  TrackerPageState createState() => TrackerPageState();
}

class TrackerPageState extends State<TrackerPage> {


  LocationAccuracy _accuracy = LocationAccuracy.best;

  bool _isTrackingEnabled = true;
  bool _showCoordinates = false;


  void _submitPoint() {

  }

  void _refreshPoint() {

  }

  Widget _pageContent(){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _lastPointCard(),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _submitPoint,
                icon: IconTheme(data: Theme.of(context).iconTheme, child: const Icon(Icons.upload)),
                label: Text(
                  "Submit Point",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _refreshPoint,
                icon: IconTheme(data: Theme.of(context).iconTheme, child: const Icon(Icons.refresh)),
                label: Text(
                  "Refresh Last Point",
                  style: Theme.of(context).textTheme.bodySmall
                ),
              ),
            ],
          ),

          const Spacer(),

          // Tracker Settings
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Tracker Settings",
                      style: Theme.of(context).textTheme.bodyLarge
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "Location Tracking",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    value: _isTrackingEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _isTrackingEnabled = value;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tracking frequency",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                            keyboardType: TextInputType.number,
                            initialValue: "30",
                            decoration: InputDecoration(
                              hintText: "e.g., 30",
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Theme.of(context).dividerColor),
                              ),
                            )
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Center(
                      child: Text(
                        "Location Accuracy",
                        style: Theme.of(context).textTheme.bodyMedium
                      ),
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ChoiceChip(
                          label: const Text("Low"),
                          selected: _accuracy == LocationAccuracy.low,
                          onSelected: (bool selected) {
                            setState(() {
                              _accuracy = LocationAccuracy.low;
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text("Medium"),
                          selected: _accuracy == LocationAccuracy.medium,
                          onSelected: (bool selected) {
                            setState(() {
                              _accuracy = LocationAccuracy.medium;
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text("High"),
                          selected: _accuracy == LocationAccuracy.high,
                          onSelected: (bool selected) {
                            setState(() {
                              _accuracy = LocationAccuracy.high;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lastPointCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Last Submitted Point",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Record Date: 31 Aug 2024, 14:00:00",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              "Place: Fake City, Fake Country",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            _showCoordinates
                ? Column(
              children: [
                Text(
                    "Coordinates: 53.534523, 41.233343",
                    style: Theme.of(context).textTheme.bodyMedium
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showCoordinates = false;
                    });
                  },
                  child: Center(
                    child: Text(
                        "Hide Coordinates",
                        style: Theme.of(context).textTheme.bodyMedium
                    ),
                  ),
                )
              ],
            )
                : TextButton(
              onPressed: () {
                setState(() {
                  _showCoordinates = true;
                });
              },
              child: Center(
                child: Text(
                  "Show Coordinates",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                "x seconds ago",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(title: "Tracker", fontSize: 40),
      body: _pageContent(),
      drawer: const CustomDrawer(),
    );
  }

}