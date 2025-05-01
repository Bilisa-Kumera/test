import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:test/shadow_icon_button.dart';

class RideScreen extends StatefulWidget {
  const RideScreen({super.key});

  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> with TickerProviderStateMixin {
  LatLng defaultCenter = LatLng(9.03, 38.74);
  LatLng? userLocation;

  bool _isDrawerOpen = false;
  late AnimationController _drawerController;
  late Animation<Offset> _drawerAnimation;

  final List<String> _allDestinations = [
    "Bole Airport",
    "Meskel Square",
    "Unity Park",
    "Addis Ababa University",
    "Friendship Park",
    "Merkato",
    "Entoto Park",
  ];

  List<String> _filteredDestinations = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredDestinations = _allDestinations;
    _drawerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
    _drawerAnimation = Tween<Offset>(begin: Offset(-1.0, 0.0), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _drawerController,
      curve: Curves.easeInOut,
    ));
    getCurrentLocation().then((pos) {
      setState(() {
        userLocation = LatLng(pos.latitude, pos.longitude);
      });
    });
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return await Geolocator.getCurrentPosition();
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredDestinations = _allDestinations
          .where((place) => place.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  final List<String> recentPlaces = [
    "Place 1",
    "Place 2",
    "Place 3",
    "Place 4",
    "Place 5",
  ];

  void _showRecentPlacesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                "Recent Places",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: recentPlaces.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        title: Text(
                          recentPlaces[index],
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                        trailing: Icon(
                          Icons.location_on,
                          color: Colors.blueAccent,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng mapCenter = userLocation ?? defaultCenter;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: mapCenter,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              if (userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userLocation!,
                      width: 40,
                      height: 40,
                      child:
                          Icon(Icons.location_pin, size: 40, color: Colors.red),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: 40,
            left: 16,
            child: ShadowIconButton(
              icon: Icons.menu,
              onTap: () {
                setState(() {
                  _isDrawerOpen = !_isDrawerOpen;
                  _isDrawerOpen
                      ? _drawerController.forward()
                      : _drawerController.reverse();
                });
              },
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: ShadowIconButton(
              icon: Icons.access_time,
              onTap: () {
                _selectTime(context);
              },
            ),
          ),
          Positioned(
            bottom: 90,
            left: 8,
            right: 10,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Good Morning, Abdi",
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey[700])),
                    SizedBox(height: 4),
                    Text("Where are you going?",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 236, 236, 236),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterSearch,
                        decoration: InputDecoration(
                          hintText: "Search Destination",
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    if (_filteredDestinations.isNotEmpty)
                      Container(
                        padding:
                            EdgeInsets.only(left: 16, right: 16, bottom: 8),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          children: _filteredDestinations.map((place) {
                            return ListTile(
                              title: Text(place),
                              onTap: () {
                                _searchController.text = place;
                                setState(() {
                                  _filteredDestinations.clear();
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                _showRecentPlacesBottomSheet(context);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 18.0),
                        child: Expanded(
                          child: Text(
                            "Recent Places",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 18.0),
                        child:
                            Icon(Icons.keyboard_arrow_up, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SlideTransition(
            position: _drawerAnimation,
            child: Container(
              width: 250,
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Menu",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 30),
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text("Home"),
                    onTap: () {
                      setState(() {
                        _isDrawerOpen = false;
                        _drawerController.reverse();
                      });
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text("Profile"),
                    onTap: () {
                      setState(() {
                        _isDrawerOpen = false;
                        _drawerController.reverse();
                      });
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.favorite),
                    title: Text("Favorite Places"),
                    onTap: () {
                      setState(() {
                        _isDrawerOpen = false;
                        _drawerController.reverse();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
