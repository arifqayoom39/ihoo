import 'package:flutter/material.dart';
import 'package:ihoo/contants/discount.dart';
import 'package:ihoo/models/cart_model.dart';
import 'package:ihoo/models/products_model.dart';
import 'package:ihoo/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ihoo/controllers/db_service.dart';

class ViewProduct extends StatefulWidget {
  const ViewProduct({super.key});

  @override
  State<ViewProduct> createState() => _ViewProductState();
}

class _ViewProductState extends State<ViewProduct> {
  Future<List<ProductsModel>>? relatedProducts;
  int _selectedImageIndex = 0;
  double _userRating = 0.0;
  bool _isSubmittingRating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final product = ModalRoute.of(context)!.settings.arguments as ProductsModel;
    relatedProducts = DbService()
        .readProducts(product.category)
        .then((docs) => ProductsModel.fromJsonList(docs))
        .then((products) => products
            .where((p) => p.id != product.id)
            .take(6)
            .toList());
  }

  Widget _buildRatingStars(double rating, int ratingCount) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.amber, size: 18));
    }
    if (hasHalfStar) {
      stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 18));
    }
    for (int i = stars.length; i < 5; i++) {
      stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 18));
    }
    stars.add(const SizedBox(width: 4));
    stars.add(Text(
      '($ratingCount)',
      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
    ));
    return Row(children: stars);
  }

  Widget _buildInteractiveRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            setState(() {
              _userRating = index + 1.0;
            });
          },
          icon: Icon(
            index < _userRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 30,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        );
      }),
    );
  }

  Future<void> _submitRating(String productId) async {
    if (_userRating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a rating first."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_isSubmittingRating) return;

    setState(() {
      _isSubmittingRating = true;
    });

    final dbService = DbService();
    final result = await dbService.updateProductRating(
      productId: productId,
      newRating: _userRating,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.startsWith("Error")
              ? "Failed to submit rating."
              : "Rating submitted successfully!"),
          backgroundColor:
              result.startsWith("Error") ? Colors.red : Colors.green,
        ),
      );
      setState(() {
        _isSubmittingRating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as ProductsModel;
    final List<String> allImages = [arguments.image, ...arguments.images];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          arguments.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, "/cart"),
          ),
        ],
        backgroundColor: const Color(0xFF2874F0),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.45,
              color: Colors.white,
              child: Stack(
                children: [
                  Center(
                    child: Hero(
                      tag: arguments.id,
                      child: CachedNetworkImage(
                        imageUrl: allImages[_selectedImageIndex],
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation(Color(0xFF2874F0)),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error, color: Color(0xFF2874F0)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                      ),
                      child: Icon(Icons.favorite_border,
                          color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
            if (allImages.length > 1)
              Container(
                height: 80,
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: allImages.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImageIndex = index;
                        });
                      },
                      child: Container(
                        width: 60,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedImageIndex == index
                                ? const Color(0xFF2874F0)
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: CachedNetworkImage(
                            imageUrl: allImages[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: Colors.grey.shade200),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error_outline, size: 30),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    arguments.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  _buildRatingStars(arguments.rating, arguments.ratingCount),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "₹${arguments.new_price}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "₹${arguments.old_price}",
                        style: TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF388E3C),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          "${discountPercent(arguments.old_price, arguments.new_price)}% off",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Rate this product",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInteractiveRatingStars(),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _isSubmittingRating
                            ? null
                            : () => _submitRating(arguments.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2874F0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: _isSubmittingRating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text("Submit"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_shipping_outlined,
                          color: Colors.grey.shade700),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "FREE delivery",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF388E3C),
                            ),
                          ),
                          Text(
                            "Delivery by ${DateTime.now().add(const Duration(days: 3)).day} ${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][DateTime.now().month - 1]}",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          color: Colors.grey.shade700),
                      const SizedBox(width: 12),
                      Text(
                        "Deliver to",
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Add Address",
                        style: TextStyle(
                          color: const Color(0xFF2874F0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Product Description",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    child: Text(
                      arguments.description,
                      style:
                          TextStyle(color: Colors.grey.shade700, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Similar Products",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 250,
                    child: FutureBuilder<List<ProductsModel>>(
                      future: relatedProducts,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text("No related products found"),
                          );
                        }
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final product = snapshot.data![index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ViewProduct(),
                                    settings:
                                        RouteSettings(arguments: product),
                                  ),
                                );
                              },
                              child: Container(
                                width: 160,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          const BorderRadius.vertical(
                                        top: Radius.circular(8),
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: product.image,
                                        height: 140,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          _buildRatingStars(product.rating,
                                              product.ratingCount),
                                          const SizedBox(height: 4),
                                          Text(
                                            "₹${product.new_price}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
      bottomSheet: arguments.maxQuantity > 0
          ? Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.white,
                      child: InkWell(
                        onTap: () {
                          Provider.of<CartProvider>(context, listen: false)
                              .addToCart(CartModel(
                                  productId: arguments.id, quantity: 1));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Added to cart successfully"),
                              backgroundColor: Color(0xFF388E3C),
                            ),
                          );
                        },
                        child: Container(
                          height: 56,
                          color: Colors.white,
                          child: const Center(
                            child: Text(
                              "ADD TO CART",
                              style: TextStyle(
                                color: Color(0xFF2874F0),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Material(
                      color: const Color(0xFFFF9F00),
                      child: InkWell(
                        onTap: () {
                          Provider.of<CartProvider>(context, listen: false)
                              .addToCart(CartModel(
                                  productId: arguments.id, quantity: 1));
                          Navigator.pushNamed(context, "/checkout");
                        },
                        child: Container(
                          height: 56,
                          color: const Color(0xFFFF9F00),
                          child: const Center(
                            child: Text(
                              "BUY NOW",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              height: 56,
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: const Text(
                "OUT OF STOCK",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }
}



