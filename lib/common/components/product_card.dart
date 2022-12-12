import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project1/common/models/product.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    Key? key,
    required this.product,
    required this.shortUrl,
  }) : super(key: key);

  final Product product;
  final String shortUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 1.w, right: 1.w),
      child: InkWell(
        onTap: () {
          GoRouter.of(context).push(
              '/$shortUrl/menu/${product.categoryId}/${product.id}',
              extra: {"comesFromDirectLink": false});
        },
        child: SizedBox(
          height: 250,
          width: 185,
          child: Stack(
            fit: StackFit.expand,
            children: [
              buildProductImage(),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
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
              Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF222222).withOpacity(.56),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(product.price.toStringAsFixed(1),
                            style: const TextStyle(
                                fontFamily: kIsWeb ? 'Metropolis' : null,
                                overflow: TextOverflow.ellipsis,
                                color: Colors.white,
                                fontSize: kIsWeb ? 15 : null,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Text(
                        product.name,
                        softWrap: true,
                        style: const TextStyle(
                          fontFamily: kIsWeb ? 'Metropolis' : null,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: kIsWeb ? 16 : 16,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      height: 30,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: ReadMoreText(
                          product.description,
                          trimLines: 1,
                          trimMode: TrimMode.Line,
                          trimCollapsedText: ' ',
                          trimExpandedText: '',
                          colorClickableText: Colors.white,
                          style: const TextStyle(
                              fontFamily: kIsWeb ? 'Metropolis' : null,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: kIsWeb ? 16 : 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ClipRRect buildProductImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: kIsWeb
          ? Image.network(
              product.image,
              width: 185,
              fit: BoxFit.cover,
            )
          : CachedNetworkImage(
              width: 185,
              fit: BoxFit.cover,
              imageUrl: product.image,
              errorWidget: (context, url, error) {
                return Center(
                    child: Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.red),
                ));
              },
              placeholder: (context, url) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              },
            ),
    );
  }
}
