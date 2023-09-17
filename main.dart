import 'dart:async';
import 'package:flutter/cupertinoicons.dart';

import 'package:fire/battery/level.dart';
import 'package:fire/battery/notification.dart';
import 'package:fire/maps/current_location_screen.dart';
import 'package:fire/maps/Mnavbar.dart';
import 'package:fire/maps/audio.dart';
import 'package:fire/maps/searchbar.dart';
import 'package:fire/auth_page.dart';
import 'package:fire/home.dart';
import 'package:fire/notification/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'Login.dart';
 import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';



void main() async{
  

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());

}


// ...




}
final navigatorKey=GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
    
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MapSample(),
      );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  @override
  Widget build(BuildContext context) => Scaffold(
    body: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(),
     builder:((context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting){
        return Center(child: CircularProgressIndicator());
      }else if(snapshot.hasError){
        return Center(child: Text('Something went wrong!'),);
      }else if (snapshot.hasData){
        return HomePage();
       }else{
        return AuthPage();
       }
     })
  ));
}
  class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
    static final Marker _kGooglePlexMarker=Marker(
        markerId: MarkerId('_kGoogleplex'),
        infoWindow: InfoWindow(title: 'Goggle plex'),
        icon: BitmapDescriptor.defaultMarker,
        position: LatLng(37.42796133580664, -122.085749655962),
        );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
      static final Marker _kLakeMarker = Marker(
        markerId: MarkerId('_kLakeMarker'),
        infoWindow: InfoWindow(title: 'Lake marker'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: LatLng(37.43296265331129, -122.08832357078792),
       );
        static final Polyline _kPolyline = Polyline(
        polylineId: PolylineId('_kPolyline'),
        points:  [LatLng(37.42796133580664, -122.085749655962),
        LatLng(37.43296265331129, -122.08832357078792),
        ],
        width: 5,

        );
        var padding = EdgeInsets.symmetric(horizontal: 18,vertical: 5);
  double gap =10;

 int _index = 0;
  List<Color> colors = [
    Colors.purple,
    Colors.pink,
    Color.fromARGB(255, 162, 157, 157),
    Colors.teal
  ];

  List<Text> text = [
    Text('Home', style:tstyle ),
    Text('Like',style: tstyle,),
    Text('Search',style: tstyle,),
    Text('User',style: tstyle,),
  ];
  PageController controller = PageController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        markers: {_kGooglePlexMarker,
            _kLakeMarker,},
            polylines: {
              _kPolyline,
            },
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    
     
      bottomNavigationBar: SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(100)),
                boxShadow: [
                  BoxShadow(
                    spreadRadius: -10,
                    blurRadius: 60,
                    color: Colors.black.withOpacity(0.4),
                    offset: Offset(0,25),
                  )
                ]
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3,vertical: 3),
              child: GNav(
                curve: Curves.fastOutSlowIn,
                duration: Duration(milliseconds: 900),
                tabs: [
                  GButton(
                    gap: gap,
                    icon: LineIcons.home,
                    iconColor: Colors.black,
                    iconActiveColor: Colors.purple,
                    text: 'Home',
                    textColor: Colors.purple,
                    backgroundColor: Colors.purple.withOpacity(0.2),
                    iconSize: 24,
                    padding: padding,
                  ),
                  GButton(
                    gap: gap,
                    icon: LineIcons.heart,
                    iconColor: Colors.black,
                    iconActiveColor: Colors.pink,
                    text: 'Like',
                    textColor: Colors.pink,
                    backgroundColor: Colors.pink.withOpacity(0.2),
                    iconSize: 24,
                    padding: padding,
                  ),
                  GButton(
                    gap: gap,
                    icon: LineIcons.search,
                    iconColor: Colors.black,
                    iconActiveColor: Colors.grey,
                    text: 'Search',
                    onPressed:(){
       Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );

      },
                    textColor: Colors.grey,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    iconSize: 24,
                    padding: padding,
                  ),
                  GButton(
                    gap: gap,
                    icon: LineIcons.user,
                    iconColor: Colors.black,
                    iconActiveColor: Colors.teal,
                    text: 'Home',
                    textColor: Colors.teal,
                    backgroundColor: Colors.teal.withOpacity(0.2),
                    iconSize: 24,
                    padding: padding,
                  ),
                ],
                selectedIndex: _index,
                onTabChange: (index){
                  setState(() {
                    _index =index;
                  });
                  controller.jumpToPage(index);
                },
              ),
            ),
          ),

      
     )
    );
    
    
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
  

  
}
    