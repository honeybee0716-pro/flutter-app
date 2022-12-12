import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:project1/common/blocs/product_detail_carrousel_bloc.dart';
import 'package:project1/common/components/product_extended_card.dart';
import 'package:project1/common/models/product.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final String proId;
  final String categoryID;
  final String restaurantShortUrl;
  final bool comesFromDirectLink;

  const ProductDetailScreen({
    Key? key,
    required this.proId,
    required this.categoryID,
    required this.restaurantShortUrl,
    this.comesFromDirectLink = false,
  }) : super(key: key);
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? currentProductId;
  final customGray = const Color(0xFF222222).withOpacity(.56);
  String imageName = " ";

  ProductDetailCarrouselBloc bloc = ProductDetailCarrouselBloc();

  @override
  void initState() {
    currentProductId = widget.proId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return StreamBuilder<List<Product>>(
              stream: bloc.streamProductByCategory(widget.categoryID),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                }
                final products = snapshot.data ?? [];
                final productIndex = products.indexWhere(
                  (element) => element.id == currentProductId,
                );
                // Means the product exist
                if (productIndex >= 0) {
                  return Center(
                    child: CarouselSlider(
                      items: products
                          .map(
                            (e) => ProductExtendedCard(
                              product: e,
                              categoryId: widget.categoryID,
                              restaurantShortUrl: widget.restaurantShortUrl,
                              comesFromDirectLink: widget.comesFromDirectLink,
                            ),
                          )
                          .toList(),
                      options: _carouselOptions(
                        products: products,
                        maxWidth: constraints.maxWidth,
                      ),
                    ),
                  );
                }
                return const Center(
                  child: Text('The product does not exist'),
                );
              },
            );
          },
        ),
      ),
    );
  }

  CarouselOptions _carouselOptions({
    required List<Product> products,
    required double maxWidth,
  }) {
    final isMobile = maxWidth <= 600;
    final isTablet = maxWidth > 600 && maxWidth <= 900;
    //final isDesktop = maxWidth > 900;
    return CarouselOptions(
      initialPage: products.indexWhere(
        (element) => element.id == currentProductId,
      ),
      disableCenter: true,
      height: 750,
      enableInfiniteScroll: false,
      viewportFraction: isMobile
          ? .9
          : isTablet
              ? .4
              : .25,
      onPageChanged: (i, c) {
        setState(
          () {
            currentProductId = products[i].id;
            imageName = products[products
                    .indexWhere((element) => element.id == currentProductId)]
                .name;
          },
        );
      },
    );
  }
}
