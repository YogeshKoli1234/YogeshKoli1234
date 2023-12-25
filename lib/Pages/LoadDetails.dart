import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';
import 'package:http/http.dart' as http;

class LoadDetails extends StatefulWidget {
  const LoadDetails(
      {super.key, required this.title, required this.id, required this.images});

  final String title;
  final String id;
  final List<dynamic> images;

  @override
  State<LoadDetails> createState() => _LoadDetails(id: id, images: images);
}

class _LoadDetails extends State<LoadDetails> {
  String id;
  List<dynamic> images;

  _LoadDetails({required this.id, required this.images});
  GoogleMapController? mapController;
  // final LatLng sourceLatLng = LatLng(37.7749, -122.4194); // Replace with your source coordinates
  // final LatLng destinationLatLng = LatLng(34.0522, -118.2437); // Replace with your destination coordinates

  bool loaderStatus = false;
  List<dynamic> visitsList = [];

  String customerName = "";
  String loanType = "";
  String loanAmount = "";
  String sanctionDate = "";
  String npaDate = "";
  String pendingAmount = "";

  double lat = 0.0;
  double long = 0.0;

  double destinationLatLat = 0.0;
  double destinationLatLng = 0.0;

  String remark = "";
  String agent = "";
  String timestamp = "";

  Set<Marker> _markers = {};
  String addresStr = "GPS Location";
  void openGoogleMapsApp() async {
    final url = 'https://www.google.com/maps/dir/?api=1&origin=${lat},${long}&destination=${destinationLatLat},${destinationLatLng}';

    print("url $url");

    await launch(url);

    // if (await canLaunch(url)) {
    // } else {
    //   throw 'Could not launch $url';
    // }
  }
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }


  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final GoogleMapController controller = await _controller.future;

      setState(() {


        controller.animateCamera(CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ));
        destinationLatLat = position.latitude;
        destinationLatLng = position.longitude;
        _markers.add(Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(title: 'Current Location'),
          icon: BitmapDescriptor.defaultMarker,
        ));
      });
    } catch (e) {
      // Handle errors if any.
      print('Error getting location: $e');
    }
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    visitDetails(id);
    _getCurrentPosition();
  }

  void visitDetails(String id) async {
    String? userTOken = await Constans().getData(StaticConstant().userToken);
    var url = Uri.parse('https://recovery.brandmetrics.in/api/v2/view-visit');

    setState(() {
      loaderStatus = true;
    });
    var formData = {'token': userTOken, 'id': id};

    print("formData $formData");
    // Make the POST request
    var response = await http.post(
      url,
      body: formData,
    );
    setState(() {
      loaderStatus = false;
    });

    if (response.statusCode == 200) {
      // Successful login
      // Parse the response if needed
      Map<String, dynamic> responseData = json.decode(response.body);
      // Do something with responseData
      print('Visites List Api: ${responseData}');
      if (responseData['status'] == "success") {
        Map<String, dynamic> accountInfo = responseData['data']['account'];
        Map<String, dynamic> visits = responseData['data']['visits'];

        // print("visits " + responseData['data']['account'].toString());
        final GoogleMapController controller = await _controller.future;

        setState(() {
          // visitsList = responseData['data']['visits'];
          customerName = accountInfo['customername'];
          loanType = accountInfo['type'];
          loanAmount = "₹ " + accountInfo['amount'];
          sanctionDate = accountInfo['sanctiondate'];
          npaDate = accountInfo['npadate'];
          pendingAmount = "₹ " + accountInfo['pendingamount'].toString();

          lat = double.parse(visits['lat']);
          long = double.parse(visits['long']);
          remark = visits['remark'].toString();
          agent = visits['agent'].toString();
          timestamp = visits['timestamp'].toString();

          getAddress(lat, long);

          setState(() {
            // _currentAddress = 'Latitude: $position.latitude, Longitude: $positionlongitude';
            controller.animateCamera(CameraUpdate.newLatLng(
              LatLng(lat, long),
            ));

            _markers.add(Marker(
              markerId: const MarkerId('currentLocation'),
              position: LatLng(lat, long),
              infoWindow: const InfoWindow(title: 'Current Location'),
              icon: BitmapDescriptor.defaultMarker,
            ));
          });

          // print("pendingAmount $pendingAmount");
        });
      }
    } else {}
  }

  Widget _buildAccountTypeList(dynamic type) {

    String image = type['image'] ?? '';
    return GestureDetector(
      onTap: () {
        // _removeImageFromList(type);
        showZoomableImage(context , type['image'] ,0);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0), // Set the desired border radius
          child: Image.network(
            image,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
    ;
  }

  Future<String?> getAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String address =
            "${placemark.street}, ${placemark.locality}, ${placemark.postalCode}, ${placemark.country}";

        print("address $address");
        setState(() {
          addresStr = address;
        });
        return address;
      } else {
        return null; // No address found
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  void showZoomableImage(BuildContext context, String image, int initialIndex) {


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(0), // Remove padding around the dialog
          child: Container(
            width: MediaQuery.of(context).size.width, // Full screen width
            height: MediaQuery.of(context).size.height, // Full screen height
            padding: EdgeInsets.all(0),
            child: PhotoViewGallery.builder(
              itemCount: 1,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  // imageProvider: NetworkImage(_imagePicker[index]),
                  imageProvider:NetworkImage( image),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  heroAttributes: PhotoViewHeroAttributes(tag: index),
                );
              },
              backgroundDecoration: BoxDecoration(
                color: Colors.black,
              ),
              pageController: PageController(initialPage: initialIndex),
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back),
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //   ),
      //   title: const Text('Visit Details'),
      // ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
        child: Stack(children: [
          SingleChildScrollView(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/ic_back.png',
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Agent : $agent",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            timestamp,
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          )
                        ],
                      )
                    ],
                  ),

                  SizedBox(
                    height: 10,
                  ),

                  Container(
                    height: 300, // Set the desired height for the map

                    child: GoogleMap(
                      markers: _markers,
                      mapType: MapType.normal,
                      initialCameraPosition: _kGooglePlex,
                      scrollGesturesEnabled: true,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                        // _goToCurrentLocation(); // Move the camera to the current location when the map is created
                      },
                    ),
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.grey,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(addresStr,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey,
                                  )),
                            ),


                            Spacer(),


                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.directions,
                              color: Colors.grey,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0),
                              child: GestureDetector(
                                onTap: () {
                                  openGoogleMapsApp();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child:   Text("Get Diretion",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                      )),
                                ),
                              ),
                            ),


                            Spacer(),


                          ],
                        ),

                      ],
                    ),
                  ),




                  Container(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Card(
                        color: Color(0xFF607080),
                        child: SizedBox(
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Text(
                                  "Customer Name",
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFFFFFFFF),
                                      fontFamily: 'Poppins'),
                                ),
                                Text(
                                  customerName,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Divider(
                                  height: 1,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Loan Type : ",
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.normal,
                                            color: Color(0xFFFFFFFF),
                                          ),
                                        ),
                                        Spacer(),
                                        Text(
                                          loanType,
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.normal,
                                            color: Color(0xFFFFFFFF),
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Loan Amount : ",
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.normal,
                                            color: Color(0xFFFFFFFF),
                                          ),
                                        ),
                                        Spacer(),
                                        Text(
                                          loanAmount,
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.normal,
                                            color: Color(0xFFFFFFFF),
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Sanction Date : ",
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.normal,
                                            color: Color(0xFFFFFFFF),
                                          ),
                                        ),
                                        Spacer(),
                                        Text(
                                          sanctionDate,
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.normal,
                                            color: Color(0xFFFFFFFF),
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Npa Date : ",
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.normal,
                                            color: Color(0xFFFFFFFF),
                                          ),
                                        ),
                                        Spacer(),
                                        Text(
                                          npaDate,
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.normal,
                                            color: Color(0xFFFFFFFF),
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Pending Amount : ",
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.normal,
                                            color: Color(0xFFFFFFFF),
                                          ),
                                        ),
                                        Spacer(),
                                        Text(
                                          pendingAmount.toString(),
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.normal,
                                            color: Color(0xFFFFFFFF),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // const SizedBox(
                  //   height: 20,
                  // ),
                  // Container(
                  //   margin: EdgeInsets.symmetric(horizontal: 10.0),
                  //   child: Card(
                  //     color: Color(0xFF607080),
                  //     child: Container(
                  //       width: double.infinity,
                  //       child: Padding(
                  //         padding: EdgeInsets.all(10.0),
                  //         child: Column(
                  //           children: [
                  //             Text(
                  //               "Agent Details",
                  //               style: TextStyle(
                  //                 fontSize: 20.0,
                  //                 fontWeight: FontWeight.w400,
                  //                 color: Color(0xFFFFFFFF),
                  //               ),
                  //             ),
                  //             SizedBox(height: 8.0),
                  //             Column(
                  //               children: [
                  //                 Row(
                  //                   mainAxisAlignment: MainAxisAlignment.center,
                  //                   children: [
                  //                     const Text(
                  //                       "Name : ",
                  //                       style: TextStyle(
                  //                         fontSize: 14.0,
                  //                         fontWeight: FontWeight.normal,
                  //                         color: Color(0xFFFFFFFF),
                  //                       ),
                  //                     ),
                  //                     SizedBox(
                  //                       width: 10,
                  //                     ),
                  //                     Text(
                  //                       agent,
                  //                       style: TextStyle(
                  //                         fontSize: 14.0,
                  //                         fontWeight: FontWeight.normal,
                  //                         color: Color(0xFFFFFFFF),
                  //                       ),
                  //                     )
                  //                   ],
                  //                 ),
                  //                 SizedBox(
                  //                   height: 5,
                  //                 ),
                  //                 Row(
                  //                   mainAxisAlignment: MainAxisAlignment.center,
                  //                   children: [
                  //                     Text(
                  //                       "Remark",
                  //                       style: TextStyle(
                  //                         fontSize: 14.0,
                  //                         fontWeight: FontWeight.normal,
                  //                         color: Color(0xFFFFFFFF),
                  //                       ),
                  //                     ),
                  //                     SizedBox(
                  //                       width: 10,
                  //                     ),
                  //                     Text(
                  //                       remark,
                  //                       style: TextStyle(
                  //                         fontSize: 14.0,
                  //                         fontWeight: FontWeight.normal,
                  //                         color: Color(0xFFFFFFFF),
                  //                       ),
                  //                     )
                  //                   ],
                  //                 )
                  //               ],
                  //             )
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  if (!images.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        child: GridView.builder(
                          scrollDirection: Axis.horizontal,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1, // Number of columns in the grid
                          ),
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            // Use _buildAccountTypeList or create your own widget here
                            return _buildAccountTypeList(images[index]);
                          },
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Remark",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: "Poppins_Light"
                            )),
                        Text(remark,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                            ))
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          if (loaderStatus)
            // Loader overlay
            Container(
              color: Colors.black.withOpacity(0.5),
              // Change the color and opacity as needed
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            )
        ]),
      ),
    );
  }
}
