
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

// Import your other files here
import '../listofall_location.dart';
import '../radarsetting.dart';
// Import your location list file here

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({Key? key}) : super(key: key);

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

const kGoogleApiKey = 'AIzaSyDSiCgGPGMrRY1HZ5cQuMAiYWK4NTJhPuI';

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(37.42796, -122.08574), zoom: 14.0);

  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  final Map<MarkerId, Marker> markers = {};

  LatLng? searchedCameraPosition;
  LatLng? currentLocation;
  Set<Marker> markersList = {};
  Set<Circle> radarCircles = {};
  late GoogleMapController googleMapController;
  final Mode _mode = Mode.overlay;
  Prediction? _selectedPrediction;
  double radarRange = 1000; // Default radar range in meters

  @override
  void initState() {
    super.initState();
    // Add a marker at the initial camera position when the map starts
    markersList.add(
      Marker(
        markerId: const MarkerId("initial_position"),
        position: initialCameraPosition.target,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: "Initial Position"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeScaffoldKey,
      appBar: AppBar(
        title: const Text("Google Search Places"),
      ),
      body: WillPopScope(
        onWillPop: () async {
          // Handle the back button press to return to the current location
          if (searchedCameraPosition != null) {
            setState(() {
              searchedCameraPosition = null; // Clear the searched position
            });
            googleMapController.animateCamera(
                CameraUpdate.newLatLng(initialCameraPosition.target));
            return false;
          }
          return true;
        },
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: initialCameraPosition,
              markers: markersList, // Add markers here
              circles: radarCircles,
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController controller) {
                googleMapController = controller;
              },
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () => _handlePressButton(),
                  icon: Icon(Icons.search),
                  label: const Text("Search Places"),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child:ElevatedButton.icon(
  onPressed: () async {
    final updatedRadarRange = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RadarSettingsPage(
          initialRadarRange: radarRange,
        ),
      ),
    );
    if (updatedRadarRange != null) {
      setState(() {
        radarRange = updatedRadarRange;
      });

      // Update radar circle for both searched and current location
      _updateRadarCircle(radarRange, location: searchedCameraPosition);
      _updateRadarCircle(radarRange, location: currentLocation);
    }
  },
  icon: Icon(Icons.settings),
  label: Text("Radar Settings"),
)

              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () => _saveLocation(),
                  icon: Icon(Icons.save),
                  label: const Text("Save Location"),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationListPage(),
                      ),
                    );
                  },
                  icon: Icon(Icons.list),
                  label: Text("View Location List"),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () => _showCurrentLocation(),
                  icon: Icon(Icons.my_location),
                  label: const Text("Current Location"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePressButton() async {
    _selectedPrediction = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      onError: onError,
      mode: _mode,
      language: 'en',
      strictbounds: false,
      types: [""],
      decoration: InputDecoration(
        hintText: 'Search',
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      components: [
        Component(Component.country, "ind"),
        Component(Component.country, "usa"),
      ],
    );

    if (_selectedPrediction != null) {
      displayPrediction(_selectedPrediction!, homeScaffoldKey.currentState);
    }
  }

  void onError(PlacesAutocompleteResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: Text(response.errorMessage ?? 'Error'),
    ));
  }

  Future<void> displayPrediction(Prediction p, ScaffoldState? currentState) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
      apiKey: kGoogleApiKey,
    );

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;

    searchedCameraPosition = LatLng(lat, lng);

    markersList.clear();
    markersList.add(
      Marker(
        markerId: const MarkerId("0"),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: detail.result.name),
      ),
    );

    setState(() {});

    googleMapController.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));
  }

void _updateRadarCircle(double radarRange, {LatLng? location}) {
  // Clear radar circles associated with the provided location
  radarCircles.removeWhere((circle) =>
      circle.circleId.value == 'radar_circle_${location?.latitude}_${location?.longitude}');

  if (location != null) {
    radarCircles.add(
      Circle(
        circleId: CircleId('radar_circle_${location.latitude}_${location.longitude}'),
        center: location,
        radius: radarRange,
        fillColor: Color.fromRGBO(0, 0, 255, 0.3),
        strokeWidth: 0,
      ),
    );
  }

  setState(() {
    this.radarRange = radarRange;
  });
}



  Future<void> _saveLocation() async {
    LatLng? locationToSave;

    if (searchedCameraPosition != null) {
      locationToSave = searchedCameraPosition;
    } else if (currentLocation != null) {
      locationToSave = currentLocation; // Use the current location if available
    }

    if (locationToSave != null) {
      final name = _selectedPrediction?.description ?? 'Current Location';
      final address =
          _selectedPrediction?.structuredFormatting?.secondaryText ?? '';

      try {
        await FirebaseFirestore.instance.collection('location').add({
          'lat': locationToSave.latitude,
          'lng': locationToSave.longitude,
          'name': name,
          'address': address,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location saved successfully.'),
          ),
        );
      } catch (e) {
        print('Error saving location: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save location.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'No location to save. Please search for a location or use the "Current Location" button.'),
        ),
      );
    }
  }

  Future<void> _showCurrentLocation() async {
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Set _selectedPrediction to null when using "Current Location" button
    _selectedPrediction = null;

    // Center the map on the user's current location
    googleMapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        14.0,
      ),
    );

    // Add a marker for the current location
    markersList.add(
      Marker(
        markerId: MarkerId("current_location"),
        position: LatLng(position.latitude, position.longitude),
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: "Current Location"),
      ),
    );

    setState(() {});

    // Use geocoding for reverse geocoding
    final List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
      localeIdentifier: 'en_US', // Set the locale for better results
    );

    if (placemarks.isNotEmpty) {
      final Placemark placemark = placemarks.first;
      final name = placemark.name ?? "No Name"; // Get location name
      final address = placemark.street ?? "No Address"; // Get location address

      // Create a Prediction object with the name and address
      _selectedPrediction = Prediction(description: '$name, $address');
    } else {
      // Handle cases where no address is found
      _selectedPrediction = Prediction(description: "No Address Found");
    }

    // Update radar circle for the current location
    _updateRadarCircle(radarRange, location: LatLng(position.latitude, position.longitude));

    setState(() {});

    // Save current location as a separate variable
    currentLocation = LatLng(position.latitude, position.longitude);
  } catch (e) {
    print('Error getting current location: $e');
  }
}

}






