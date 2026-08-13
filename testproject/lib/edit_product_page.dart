import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class EditProductPage extends StatefulWidget {
  final Map product;
  EditProductPage({required this.product});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final String baseUrl = 'http://10.0.2.2:3000';

  @override
  void initState() {
    super.initState();
    // Auto-fill existing details from the item card data map
    _nameController.text = widget.product['name'] ?? '';
    _priceController.text = widget.product['price']?.toString() ?? '';
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _updateProduct() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      return;
    }

    var request = http.MultipartRequest(
      'PUT', 
      Uri.parse('$baseUrl/products/${widget.product['id']}')
    );
    request.fields['name'] = _nameController.text;
    request.fields['price'] = _priceController.text;

    // Send a new photo file only if the admin modified it
    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      Navigator.pop(context, true); // Send true back to force an item data list refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text("Modify Details ✏️", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.blue[100]!, width: 2),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : widget.product['image_url'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.network('$baseUrl/images/${widget.product['image_url']}', fit: BoxFit.cover),
                          )
                        : Icon(Icons.add_photo_alternate_rounded, size: 50, color: Colors.grey),
              ),
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: "Product Name",
                      prefixIcon: Icon(Icons.shopping_bag_outlined, color: Colors.blue[300]),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Price",
                      prefixIcon: Icon(Icons.payments_outlined, color: Colors.blue[300]),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _updateProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[400],
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              child: Text("Save Changes ✨", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}