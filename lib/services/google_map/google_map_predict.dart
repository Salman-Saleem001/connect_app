import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:connect_app/services/google_map/api_service.dart';
import 'package:connect_app/services/google_map/map_key.dart';

import 'address_model.dart';
import 'google_address_model.dart';
import 'google_map_functions.dart';

class GoogleMapPredict extends StatefulWidget {
  final ValueChanged<PickLocationData>? address;
  const GoogleMapPredict({super.key, this.address});

  @override
  State<GoogleMapPredict> createState() => _GoogleMapPredictState();
}

class _GoogleMapPredictState extends State<GoogleMapPredict> {
  final ApiRequest _apiRequests = ApiRequest();
  /*get latlng From address*/
  Future getLatLngFromAddress(String address) async {
    GoogleAddressModel googleAddressModel = GoogleAddressModel();
    debugPrint(getLatLngFromAddressUrl(address, MapKey.mapKey));
    await _apiRequests.getMap(
        url: getLatLngFromAddressUrl(address, MapKey.mapKey),
        onSuccess: (res) async {
          googleAddressModel = GoogleAddressModel.fromJson(jsonDecode(res));
          widget.address!(PickLocationData(
              lat: googleAddressModel.results?.first.geometry?.location?.lat?.toDouble() ?? 0,
              lng: googleAddressModel.results?.first.geometry?.location?.lng?.toDouble() ?? 0,
              country:"",
              city: "",
              state:"",
              zipCode:"",
          streetAddress: googleAddressModel.results?.first.formattedAddress ?? "",));
          // setState(() {});
        },
        onError: (e) {
          debugPrint(e.toString());
        });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (GoogleMapFunctions.predictions != null && GoogleMapFunctions.isList) {
      return Container(
        padding: const EdgeInsets.only(top: 10.0),
        height: 200,
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(
                GoogleMapFunctions.predictions!.predictions.length, (index) {
              return GestureDetector(
                onTap: () async {
                  GoogleMapFunctions.isList = false;

                  await getLatLngFromAddress(GoogleMapFunctions
                      .predictions!.predictions[index].fullText);
                  // setState(() {});
                },
                child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    color: Colors.white,
                    child: Column(
                      children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: MediaQuery.sizeOf(context).width * 0.03),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  //  width: Get.width*0.8,
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: Text(
                                        GoogleMapFunctions.predictions!
                                            .predictions[index].fullText,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    )),
                                Transform.rotate(
                                    angle: 40 * pi / 180,
                                    child: const MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: Icon(
                                          Icons.arrow_upward_outlined,
                                          color: Colors.grey,
                                        )))
                              ],
                            ),
                          ),
                        ),
                        const Divider(
                          color: Colors.grey,
                          thickness: 1,
                          indent: 20,
                          endIndent: 20,
                        )
                      ],
                    )),
              );
            }),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
