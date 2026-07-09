import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkImageCustom extends StatelessWidget {
  final String? image;
  final double height;
  final double width;
  final BoxFit? fit;

  const NetworkImageCustom(
      {super.key, this.height = double.infinity, this.width = double.infinity, this.image, this.fit});

  @override
  Widget build(BuildContext context) {
    // bool isAbsolute= Uri.parse(image??'').isAbsolute;
    return CachedNetworkImage(
        // placeholder: ((context, url) => Image.asset(AppImages.ic_place_holder)),
        imageUrl: image ?? '',
        height: height,
        width: width,
        errorWidget: (context, url, error) => Icon(
              Icons.account_circle,
              size: width,
              color: Colors.grey,
            ),
        fit: fit ?? BoxFit.contain);
  }
}
