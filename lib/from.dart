import 'package:flutter/material.dart';
import 'main.dart' show Product; // simple re‑use of the model

class ProductBox extends StatelessWidget {
  const ProductBox({
    super.key,
    required this.product,
    this.highlightColor,
  });

  final Product product;
  final Color? highlightColor;

/* ------------------------------  Dialog  ----------------------------- */
  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(product.name),
        content: Text(product.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

/* ------------------------------  Card  ------------------------------- */
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 120,
      child: Material(
        color: highlightColor ?? Colors.white,
        elevation: highlightColor != null ? 6 : 3,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showDialog(context),
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Icon(Icons.drag_indicator, color: Colors.grey),
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/download.jpg',
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      Text(product.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 13)),
                      Text('Price: \$${product.price}',
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
