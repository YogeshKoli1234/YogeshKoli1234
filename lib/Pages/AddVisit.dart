import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';

class AddVisit extends StatefulWidget {
  final String accountNum;
  final Function(String) refreshFunction;

  // const AddVisit({Key? key, required this.title, required this.accountNum});
  const AddVisit(  {super.key, required this.title, required this.accountNum, required this.refreshFunction});

  final String title;

  @override
  State<AddVisit> createState() => _AddVisit(accountNum: accountNum ,refreshFunction:refreshFunction);
}

class _AddVisit extends State<AddVisit> {
  late GoogleMapController mapController;
  final Function(String) refreshFunction;

  String accountNum;

  TextEditingController _account = TextEditingController();
  TextEditingController _remark = TextEditingController();

  Position? _currentPosition;
  bool loaderStatus = false;

  double lat = 0.0;
  double long = 0.0;

  String addresStr = "GPS Location";

  Set<Marker> _markers = {};
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  late File imageFile;
  List<Image> _pickedImages = [];
  List<File> _files = [];

  late ImagePicker _imagePicker;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  _AddVisit({required this.accountNum,required this.refreshFunction});

  Future<void> _goToCurrentLocation() async {
    final GoogleMapController controller = await _controller.future;
    KeyboardVisibilityController keyboardVisibilityController =
        KeyboardVisibilityController();

    // Check if the current position is available
    if (_currentPosition != null) {
      // Move the camera to the current position
      controller.animateCamera(CameraUpdate.newLatLng(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();

    _imagePicker = ImagePicker();
    _account.text = accountNum.toString();
    // openLocationSettings();
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
        lat = position.latitude;
        long = position.longitude;
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

  void _removeImageFromList(Image item) {
    setState(() {
      _pickedImages.remove(item);
    });
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await _imagePicker.getImage(source: ImageSource.camera);

      if (pickedFile != null) {
        _files.add(File(pickedFile.path));

        Widget? item = null;
        setState(() {
          _pickedImages.add(Image.file(
            File(pickedFile.path),
            width: 100,
            height: 100,
            fit: BoxFit.fill,
          ));
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> showToast(String str) async {
    Fluttertoast.showToast(
      msg: str,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  upload(List<File> imageFile) async {
    // open a bytestream
    // var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));

    if (_account.text.isEmpty) {
      showToast("Please Enter Acount Number");
    } else if (_remark.text.isEmpty) {
      showToast("Please Enter Remark");
    } else {
      setState(() {
        loaderStatus = true;
      });

      // string to uri
      var uri = Uri.parse("https://recovery.brandmetrics.in/api/v2/add-visit");

      // create multipart request
      var request = http.MultipartRequest("POST", uri);

      String? userTOken = await Constans().getData(StaticConstant().userToken);

      request.fields['token'] = userTOken!;
      request.fields['accountno'] = _account.text; // Add more fields as needed
      request.fields['gps_lat'] = lat.toString(); // Add more fields as needed
      request.fields['gps_long'] = long.toString(); // Add more fields as needed
      request.fields['remark'] = _remark.text; // Add more fields as needed

      // Iterate through the list of image files
      for (var i = 0; i < imageFile.length; i++) {
        // Create a new http.MultipartFile from each File
        var stream = http.ByteStream(imageFile[i].openRead());
        var length = await imageFile[i].length();
        var multipartFile = http.MultipartFile(
          'image',
          stream,
          length,
          filename: imageFile[i].path,
        );

        // Add each MultipartFile to the request.files list
        request.files.add(multipartFile);
      }
      //

      // send
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var parsedJson = json.decode(responseBody);
      setState(() {
        loaderStatus = false;
      });
      // Access the values
      var status = parsedJson['status'];
      var message = parsedJson['message'];
      showToast(message);
      refreshFunction("");

      Navigator.pop(context, true);
      // listen for response
      // response.stream.transform(utf8.decoder).listen((value) {
      //   print(value);
      // });
    }
  }

  Widget _buildAccountTypeList(List<Image> accounts) {

    // showZoomableImage
    return Row(
      children: accounts.map((type) {
        return GestureDetector(
          onTap: () {
            // _removeImageFromList(type);
            showZoomableImage(context , _pickedImages ,0);
          },
          child: Card(
            color: Color(0xFFFFFFFF),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.black),
              borderRadius:
                  BorderRadius.circular(8.0), // Set the desired border radius
            ),
            child: Container(
              width: 100,
              child: Container(
                child: Stack(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        // Set the desired border radius
                        child: type),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          _removeImageFromList(type);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Image.asset(
                            'assets/ic_cross.png',
                            width: 15,
                            height: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void showZoomableImage(BuildContext context, List<Image> imageUrls, int initialIndex) {
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
              itemCount: imageUrls.length,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  // imageProvider: NetworkImage(_imagePicker[index]),
                  imageProvider: imageUrls[index].image,
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

  Future<String?> getAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String address = "${placemark.street}, ${placemark.locality}, ${placemark.postalCode}, ${placemark.country}";


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      // appBar: AppBar(
      //   title: const Text('Add Visit'),
      // ),
      body: Stack(children: [
        SingleChildScrollView(
          child: Column(
            children: [

              SizedBox(height: 50),

              Container(
                height: 300,
                child: GoogleMap(
                  markers: _markers,
                  mapType: MapType.normal,
                  initialCameraPosition: _kGooglePlex,
                  scrollGesturesEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    _goToCurrentLocation(); // Move the camera to the current location when the map is created
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.grey,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child:  Text(addresStr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey,
                          )),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () {
                    getAddress(lat ,long);
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Color(0xFF456EFE),
                      // Set the background color to #456EFE
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            8.0), // Set the desired border radius
                      ) // Set width and height
                      ),
                  child: const Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_searching_outlined,
                        color: Color(0xFFFFFFFF),
                        size: 20,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Capture GPS Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFFFFFFFF),
                            fontFamily: "Poppins",
                          )),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () {
                    _pickImage();
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Color(0xFF456EFE),
                      // Set the background color to #456EFE
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            8.0), // Set the desired border radius
                      ) // Set width and height
                      ),
                  child: const Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        color: Color(0xFFFFFFFF),
                        size: 20,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Take Customer Images',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFFFFFFFF),
                            fontFamily: "Poppins",
                          )),
                    ],
                  ),
                ),
              ),
              if (_pickedImages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Container(
                    height: 100,
                    width: 10000,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildAccountTypeList(_pickedImages),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20,8,20,8),
                child: Theme(
                  data: ThemeData(
                    inputDecorationTheme: const InputDecorationTheme(
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        // padding: EdgeInsets.symmetric(vertical: 20),
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(
                                4.0), // Set the desired border radius
                          ),
                          child: Container(
                            color: Color(0xFFFFFFFF),
                            height: 150,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                  controller: _remark,
                                  decoration: const InputDecoration(

                                    isDense: true,
                                    floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                    labelText:
                                    'Remark',
                                    filled: true,
                                    fillColor: Color(0xFFFFFFFF),
                                    labelStyle: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14.0,
                                    ),
                                  )),
                            ),
                          ),
                        ),
                      )],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [

                    Flexible(
                      flex: 1,
                      child: ElevatedButton(

                        onPressed: () {
                          // _uploadImages();

                          upload(_files);
                        },
                        style: ElevatedButton.styleFrom(
                            primary: Color(0xFF456EFE),
                            // Set the background color to #456EFE
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Set the desired border radius
                            ) // Set width and height
                            ),

                        child: const Text('Submit',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFFFFF),
                            )),
                      ),
                    ),
                    SizedBox(width: 10,),
                    Flexible(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () {
                          // _uploadImages();

                          // upload(_files);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            primary:Colors.grey.withOpacity(0.1),
                            // Set the background color to #456EFE
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Set the desired border radius
                            ) // Set width and height
                        ),
                        child: const Text('Cancel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5D5D5D),
                            )),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
        if (loaderStatus)
          // Loader overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              // Change the color and opacity as needed
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          )
      ]),
    );
  }
}
