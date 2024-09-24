import 'package:dawarich/containers/preferences.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/widgets/appbar.dart';
import 'package:dawarich/widgets/drawer.dart';

class TrackerPage extends StatefulWidget {

  const TrackerPage({super.key});

  @override
  TrackerPageState createState() => TrackerPageState();
}

class TrackerPageState extends State<TrackerPage> {

  final Preferences _preferences = Preferences();

  final List<bool> _selectedOnOff = [true, false];
  final List<bool> _selectedAccuracy = [false, false, true];

  Widget _infoRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              key,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _manualButton(IconData displayIcon, String bottomText, double width, double height, VoidCallback onTap){
    return InkWell(
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).dividerColor,
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        width: width,
        height: height,
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Icon(displayIcon, size: 20),
            ),
            const SizedBox(height: 20),
            Text(
              bottomText,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      )
    );

  }

  void _submitPoint() {

  }

  void _refreshLastPoint() {

  }
  
  Padding _buttonSetting(String label, List<bool> selectedButtons, List<Widget> buttonChildren, double width, double height) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 10.0),
          ToggleButtons(
            borderRadius: BorderRadius.circular(8.0),
            isSelected: selectedButtons,
            //onPressed: callback,
            children: buttonChildren.map((child) {
              return SizedBox(
                width: width,
                child: Center(child: child),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Padding _textSetting(String label, ){
  //
  // }

  Widget _pageContent(){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).dividerColor,
                  spreadRadius: 2.0,
                  blurRadius: 5.0,
                  offset: const Offset(0, 2)
                )
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child:
                  Text(
                    "Last submitted point: ",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 10),
                _infoRow("Record Date:", "31 Aug 2024 14:00:00"),
                _infoRow("Coordinates:", "53.534523, 41.233343"),
                _infoRow("Address:", "Fakestreet 33"),
                _infoRow("Place:", "Fake City, fake Country"),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    "x seconds ago",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              _manualButton(Icons.upload, "Submit point", 165, 90, _submitPoint),
              const Spacer(),
              _manualButton(Icons.download, "Refresh last point", 165, 90, _refreshLastPoint),
            ],
          ),
          const SizedBox(height: 30),
          Center(
            child: Text(
              "Tracker settings",
              style: Theme.of(context).textTheme.bodyLarge
            ),
          ),
          const SizedBox(height: 30),
          _buttonSetting(
            "Location tracking",
            _selectedOnOff,
            [
              Text(
                "On",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                "Off",
                style: Theme.of(context).textTheme.bodySmall,
              )
            ],
            105,
            30
          ),
          _buttonSetting(
            "Location accuracy",
            _selectedAccuracy,
            [
              Text(
                "Low",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                "Medium",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                "High",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            70,
            30
          )
        ],
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