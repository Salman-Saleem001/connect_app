import 'package:flutter/material.dart';
import 'package:connect_app/globals/container_properties.dart';
import 'package:connect_app/globals/network_image.dart';
import 'package:connect_app/utils/text_styles.dart';
import 'package:connect_app/widgets/primary_button.dart';

class CartItemComponent extends StatelessWidget {
  const CartItemComponent({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 10, top: 10, bottom: 10, left: 5),
      width: 170,
      decoration: ContainerProperties.shadowDecoration(),
      child: Column(
        children: [
          SizedBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 65,
                  width: 65,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: const NetworkImageCustom(
                        height: 65,
                        width: 65,
                        image:
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSoTiY5qr6wUqTCmLCb3kW_9k4PqpNq-ExFjw&usqp=CAU',
                      )),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('\$50',
                          maxLines: 1, style: subHeadingText(size: 16)),
                      Text(
                        "Panadol",
                        maxLines: 2,
                        style: headingText(size: 13),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Lorem Ipsum is simply dummy text of the printing.',
            maxLines: 3,
            style: lightText(size: 13),
          ),
          const SizedBox(
            height: 8,
          ),
          const Spacer(),
          Container(
            alignment: Alignment.center,
            height: 50,
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                SizedBox(
                  width: 120,
                  height: 40,
                  child: PrimaryButton(
                    label: 'Add to cart',
                    onPress: () {},
                    color: null,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
