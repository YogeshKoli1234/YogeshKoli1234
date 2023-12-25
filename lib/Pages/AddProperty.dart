import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FirstScreen(),
    );
  }
}

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  String dataFromSecondScreen = '';

  // Function to refresh data
  String refreshData() {
    // Replace this with the actual logic to refresh your data
    print('Refreshing data...');
    setState(() {
      // Simulating updated data
      dataFromSecondScreen = 'Refreshed Data';
    });
    return 'Refreshed Data';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Navigate to the second screen and pass the refresh function
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SecondScreen(refreshData)),
            );

            // Perform some action when returning from the second screen
            if (result != null) {
              // Update the state with the result data
              setState(() {
                dataFromSecondScreen = result;
              });
            }
          },
          child: Text('Go to Second Screen'),
        ),
      ),
      // Display the data from the second screen
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Text('Data from Second Screen: $dataFromSecondScreen'),
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  final Function() refreshFunction;

  SecondScreen(this.refreshFunction);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Call the refresh function on the first screen
            String result = refreshFunction();
            // Return data to the first screen
            Navigator.pop(context, result);
          },
          child: Text('Refresh and Go Back to First Screen'),
        ),
      ),
    );
  }
}
