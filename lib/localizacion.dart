import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'dart:async';


class Localizacion extends StatefulWidget {
  Localizacion({Key key}) : super(key: key);

  @override
  _LocalizacionState createState() => _LocalizacionState();
}

class _LocalizacionState extends State<Localizacion> {
  LocationData localizacionActual;
  StreamSubscription<LocationData> _subscriptionLocalizacion;
  Location _servicioLocalizacion = Location();
  bool _permiso = false;

  @override
  void initState() {
     super.initState();
    initPlatformState();

  }

  initPlatformState() async {
    await _servicioLocalizacion.changeSettings(
        accuracy: LocationAccuracy.HIGH, interval: 1000);

    LocationData location;

    try {
      var serviceStatus = await _servicioLocalizacion.serviceEnabled();
      print('Service status: $serviceStatus');
      if (serviceStatus) {
        _permiso = await _servicioLocalizacion.requestPermission();
        print('Permission: $_permiso');
        if (_permiso) {
          location = await _servicioLocalizacion.getLocation();

          _subscriptionLocalizacion = _servicioLocalizacion
              .onLocationChanged()
              .listen((LocationData result) async {
           

            if (mounted) {
              setState(() {
                localizacionActual = result;
            
              });
            }
            if (localizacionActual != null) {
              // final response = await http
              //     .post("http://$SERVER_NAME/api/ActualizarLatLng", body: {
              //   "idC": this.widget.id.toString(),
              //   "latitud": localizacionActual.latitude.toString(),
              //   "longitud": localizacionActual.longitude.toString()
              // });
              //  print(response.body);
            }
          });
        }
      } else {
        var serviceStatusResult = await _servicioLocalizacion.requestService();
      
        if (serviceStatusResult) {
          initPlatformState();
        }
      }
    } catch (e) {
      print(e);
      location = null;
    }

  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text('Ubicacion'),
      ),
      body: FlutterMap(
        options: new MapOptions(
          // onTap: (LatLng location) {
          //   setState(() {
          //     latitud = location.latitude;
          //     longitud = location.longitude;
          //   });
          //   print(location.latitude);
          //   print(location.longitude);
          // },
          center: localizacionActual != null
              ? LatLng(localizacionActual.latitude, localizacionActual.longitude)
              : LatLng(-17.812897, -63.230304),
          zoom: 13.0,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate:
                'https://api.mapbox.com/styles/v1/studentcat/cjxtdziti89121cmp4juodris/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic3R1ZGVudGNhdCIsImEiOiJjanh0Yjd2azAwYmE0M2NxbHlvdWxyMWhzIn0.3LH2RusySekdeGEfRWoCTw',
            additionalOptions: {
              'accessToken':
                  'pk.eyJ1Ijoic3R1ZGVudGNhdCIsImEiOiJjanh0Yjd2azAwYmE0M2NxbHlvdWxyMWhzIn0.3LH2RusySekdeGEfRWoCTw',
              'id': 'mapbox.mapbox-streets-v7'
            },
          ),
          new MarkerLayerOptions(
            markers: [
              new Marker(
                width: 80.0,
                height: 80.0,
                point: localizacionActual != null
                    ? LatLng(
                        localizacionActual.latitude, localizacionActual.longitude)
                    : LatLng(-17.812897, -63.230304),
                builder: (ctx) => new Container(
                  child: IconButton(
                    icon: Icon(Icons.location_on),
                    color: Colors.red,
                    iconSize: 45.0,
                    onPressed: () {
                      print('Marker tapped');
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
