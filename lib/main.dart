import 'package:flutter/material.dart';
import 'from.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Efficient Drag & Delete',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const MyHomePage(title: 'Re-order & Delete Products'),
    );
  }
}

/* -------------------------  IMMUTABLE MODEL  ------------------------- */
@immutable
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
  });

  final int id;
  final String name;
  final String description;
  final int price;
  final String image;
}

/* ---------------------------  HOME PAGE  ---------------------------- */
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const double _tileHeight = 128;

  final List<Product> _products = [
    const Product(
        id: 1,
        name: 'iPhone',
        description: 'iPhone is the stylist phone ever',
        price: 1000,
        image: 'downloads'),
    const Product(
        id: 2,
        name: 'Pixel',
        description: 'Pixel is the most featureful phone ever',
        price: 800,
        image: 'pixel.png'),
    const Product(
        id: 3,
        name: 'Laptop',
        description: 'Laptop is the most productive development tool',
        price: 2000,
        image: 'laptop.png'),
    const Product(
        id: 4,
        name: 'Tablet',
        description: 'Tablet is the most useful device ever for meeting',
        price: 1500,
        image: 'tablet.png'),
    const Product(
        id: 5,
        name: 'Pendrive',
        description: 'Pendrive is useful storage medium',
        price: 100,
        image: 'pendrive.png'),
    const Product(
        id: 6,
        name: 'Floppy Drive',
        description: 'Floppy drive is useful rescue storage medium',
        price: 20,
        image: 'floppy.png'),
  ];

  Product? _recentlyDeleted;
  int? _recentlyDeletedIndex;

/* ------------------------  REORDER (linked list)  ------------------- */
  void _moveItem(int from, int to) {
    if (from == to) return;
    setState(() {
      final moving = _products.removeAt(from);
      final insertIndex = from < to ? to : to + 1; // AFTER target
      _products.insert(insertIndex, moving);
    });
  }

/* -----------------------------  DELETE  ----------------------------- */
  void _deleteItem(int index) {
    setState(() {
      _recentlyDeleted = _products.removeAt(index);
      _recentlyDeletedIndex = index;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Text('${_recentlyDeleted!.name} deleted'),
        action: SnackBarAction(label: 'UNDO', onPressed: _undoDelete),
      ),
    );
  }

  void _undoDelete() {
    if (_recentlyDeleted == null) return;
    setState(() {
      _products.insert(_recentlyDeletedIndex!, _recentlyDeleted!);
      _recentlyDeleted = null;
      _recentlyDeletedIndex = null;
    });
  }

/* -----------------------------  UI  ----------------------------- */
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView.builder(
        key: const PageStorageKey('product-list'),
        itemExtent: _tileHeight, // ? fixed height for fast layout
        cacheExtent: _tileHeight * 12, // pre-cache 12 rows
        itemCount: _products.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final product = _products[index];

          return DragTarget<int>(
            onWillAccept: (from) => from != index,
            onAccept: (from) => _moveItem(from, index),
            builder: (context, candidate, _) {
              final hovering = candidate.isNotEmpty;

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Dismissible(
                  key: ValueKey(product.id),
                  direction: DismissDirection.startToEnd,
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 24),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child:
                        const Icon(Icons.delete, color: Colors.white, size: 28),
                  ),
                  onDismissed: (_) => _deleteItem(index),

                  /* ---------------  Draggable --------------- */
                  child: LongPressDraggable<int>(
                    data: index,
                    feedback: Transform.scale(
                      scale: 1.06,
                      child: Material(
                        elevation: 10,
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: width,
                          child: ProductBox(product: product),
                        ),
                      ),
                    ),
                    childWhenDragging: const SizedBox(
                      height: _tileHeight,
                      child: Center(
                          child: Text('Moving…',
                              style: TextStyle(color: Colors.grey))),
                    ),
                    child: ProductBox(
                      product: product,
                      highlightColor: hovering
                          ? Colors.lightGreenAccent.withOpacity(.45)
                          : null,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
