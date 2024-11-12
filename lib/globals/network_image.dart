import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkImageCustom extends StatelessWidget {
  final String? image;
  final double height;
  final double width;
  final BoxFit? fit;

  const NetworkImageCustom(
      {super.key,
      this.height = double.infinity,
      this.width = double.infinity,
      required this.image,
      this.fit});

  @override
  Widget build(BuildContext context) {
    bool isAbsolute= Uri.parse(image??'').isAbsolute;
    return CachedNetworkImage(
        // placeholder: ((context, url) => Image.asset(AppImages.ic_place_holder)),

        imageUrl: isAbsolute? image??'' : 'https://cdn-icons-png.flaticon.com/512/61/61205.png',
        height: height,
        width: width,
        errorWidget: ((context, url, error) => const Icon(Icons.account_circle,size: 60,color: Colors.grey,)),
        fit: fit != null ? fit! : BoxFit.contain);
  }
}
