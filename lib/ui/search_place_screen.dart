import 'package:flutter/material.dart';
import 'package:flutter_maps_bloc/bloc/search_place_bloc.dart';
import 'package:flutter_maps_bloc/ui/drag_map_screen.dart';
import 'package:google_maps_webservice/places.dart';

class SearchPlaceScreen extends StatefulWidget {
  final double lat;
  final double lng;

  SearchPlaceScreen({@required this.lat, @required this.lng});

  @override
  _SearchPlaceScreenState createState() => _SearchPlaceScreenState();
}

class _SearchPlaceScreenState extends State<SearchPlaceScreen> {
  final SearchPlaceBloc _searchPlaceBloc = SearchPlaceBloc();

  /// Override functions
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search address'),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(hintText: 'Type the address'),
              onChanged: (String value) =>
                  _searchPlaceBloc.searchPlace(value, widget.lat, widget.lng),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: StreamBuilder<bool>(
              stream: _searchPlaceBloc.isLoading,
              builder:
                  (BuildContext context, AsyncSnapshot<bool> loadingSnapshot) {
                if (loadingSnapshot.hasData) {
                  if (loadingSnapshot.data)
                    return Center(child: CircularProgressIndicator());
                  else
                    return _buildPlaceList();
                } else {
                  return Container();
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'Place Map',
        onPressed: () async {
          final dynamic destinationResult = await Navigator.push(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) =>
                  DragMapScreen(lat: widget.lat, lng: widget.lng),
            ),
          );

          if (destinationResult != null) {
            _returnToMapScreen(
              destinationResult.formattedAddress,
              destinationResult.latitude,
              destinationResult.longitude,
            );
          }
        },
        child: Icon(Icons.person_pin_circle),
        tooltip: 'Get destination from map',
      ),
    );
  }

  /// Widget functions
  Widget _buildPlaceList() {
    return StreamBuilder<List<PlacesSearchResult>>(
      stream: _searchPlaceBloc.placeList,
      builder: (BuildContext context,
          AsyncSnapshot<List<PlacesSearchResult>> placesSnapshot) {
        if (placesSnapshot.hasData) {
          if (placesSnapshot.data.isNotEmpty) {
            final List<PlacesSearchResult> places = placesSnapshot.data;

            return ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: places.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text(places[index].formattedAddress),
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());

                    _returnToMapScreen(
                        places[index].formattedAddress,
                        places[index].geometry.location.lat,
                        places[index].geometry.location.lng);
                  },
                );
              },
            );
          } else {
            return Container();
          }
        } else {
          return Container();
        }
      },
    );
  }

  /// Functions
  void _returnToMapScreen(String address, double lat, double lng) {
    final List<dynamic> data = <dynamic>[];

    data.add(address);
    data.add(lat);
    data.add(lng);

    Navigator.pop(context, data);
  }
}
