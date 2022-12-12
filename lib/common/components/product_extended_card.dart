import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project1/common/models/product.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

class ProductExtendedCard extends StatelessWidget {
  ProductExtendedCard({
    Key? key,
    required this.product,
    required this.categoryId,
    required this.restaurantShortUrl,
    this.comesFromDirectLink = false,
  }) : super(key: key);

  final Product product;
  final String? categoryId;
  final String restaurantShortUrl;
  final bool comesFromDirectLink;

  final customGray = const Color(0xFF222222).withOpacity(.56);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: SizedBox(
        width: 380,
        child: Stack(
          fit: StackFit.expand,
          children: [
            buildProductImage(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black87.withOpacity(0.2),
                    Colors.black87,
                  ],
                ),
              ),
            ),
            buildProductInformation(),
            if (!kIsWeb) buildShareButton(context),
            buildBackButton(context),
          ],
        ),
      ),
    );
  }

  Widget buildProductInformation() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              color: customGray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product.price.toStringAsFixed(1),
                style: const TextStyle(
                  fontFamily: kIsWeb ? 'Metropolis' : null,
                  overflow: TextOverflow.ellipsis,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: kIsWeb ? 22 : 32,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 16,
            ),
            child: Text(
              product.name,
              softWrap: true,
              style: const TextStyle(
                fontFamily: kIsWeb ? 'Metropolis' : null,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 45.0),
                  child: ReadMoreText(
                    product.description,
                    trimLines: 2,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: ' ',
                    trimExpandedText: '',
                    colorClickableText: Colors.white,
                    style: const TextStyle(
                        fontFamily: kIsWeb ? 'Metropolis' : null,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ClipRRect buildProductImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: kIsWeb
          ? Image.network(
              product.image,
              height: 780,
              fit: BoxFit.cover,
            )
          : CachedNetworkImage(
              fit: BoxFit.cover,
              height: 780,
              imageUrl: product.image,
              errorWidget: (context, url, error) {
                return Center(
                  child: Text(
                    error.toString(),
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              },
              placeholder: (context, url) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
            ),
    );
  }

  Widget buildBackButton(BuildContext context) {
    return Positioned(
      left: 16,
      top: 16,
      child: GestureDetector(
        onTap: () {
          // Adjust the OnTap action depending on whether the page was created from the menu page of was directly accessed using a link.
          if (!comesFromDirectLink) {
            Navigator.of(context).pop();
          } else {
            GoRouter.of(context).push('/$restaurantShortUrl/menu');
          }
        },
        child: CircleAvatar(
          backgroundColor: customGray,
          child: const Center(
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildShareButton(BuildContext context) {
    return Positioned(
      bottom: 10,
      right: 10,
      child: Material(
        color: Colors.transparent,
        type: MaterialType.button,
        child: IconButton(
          splashRadius: 2.5.h,
          onPressed: () async {
            Share.share(//"Check this cool product that I found: " +
                "https://menu.mynuutheapp.com/#/$restaurantShortUrl/menu/$categoryId/${product.id}");
          },
          icon: const Icon(
            CupertinoIcons.share,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}
