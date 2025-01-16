import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  late Box<String> categoryBox;
  bool isLoading = true; // حالة التحميل

  Future<void> initializeCategories() async {
    final categoryBox = await Hive.openBox<String>('category_box');

    // قائمة الفئات الافتراضية
    final defaultCategories = [
      'Food & Drinks',
      'Shopping',
      'Healthcare',
      'Transportation',
      'Entertainment',
      'Bills',
      'Other',
    ];

    // التحقق من الفئات الناقصة وإضافتها
    final missingCategories = defaultCategories.where(
          (category) => !categoryBox.values.contains(category),
    );

    if (missingCategories.isNotEmpty) {
      categoryBox.addAll(missingCategories);
    } else {
    }
  }


  @override
  void initState() {
    super.initState();
    openBox();
  }

  Future<void> openBox() async {
    categoryBox = await Hive.openBox<String>('category_box');
    setState(() {
      isLoading = false; // تم فتح الصندوق
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Manage Categories')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Manage Categories')),
      body: ValueListenableBuilder(
        valueListenable: categoryBox.listenable(),
        builder: (context, Box<String> box, _) {
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final category = box.getAt(index);
              return ListTile(
                title: Text(category!),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    box.deleteAt(index);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final TextEditingController _categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Category'),
        content: TextField(
          controller: _categoryController,
          decoration: InputDecoration(hintText: 'Category Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_categoryController.text.isNotEmpty) {
                categoryBox.add(_categoryController.text);
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}
