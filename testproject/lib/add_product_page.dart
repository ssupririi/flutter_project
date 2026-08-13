import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  Uint8List? selectedImage;
  final picker = ImagePicker();
  final String baseUrl = 'http://10.0.2.2:3000';

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() { selectedImage = bytes; });
    }
  }

  Future<void> uploadProduct() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty || selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields and pick an image")));
      return;
    }

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/products'));
    request.fields['name'] = nameController.text;
    request.fields['price'] = priceController.text;

    request.files.add(http.MultipartFile.fromBytes(
      'image',
      selectedImage!,
      filename: 'product.png', // Corrected for PNG
      contentType: MediaType('image', 'png'), // Corrected for PNG
    ));

    try {
      final streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Product")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Product Name")),
            TextField(controller: priceController, decoration: InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
            SizedBox(height: 20),
            Container(
              height: 150, width: double.infinity,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: selectedImage != null 
                  ? Image.memory(selectedImage!, fit: BoxFit.cover)
                  : Center(child: Text("No image selected")),
            ),
            ElevatedButton(onPressed: pickImage, child: Text("Pick PNG Image")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: uploadProduct, child: Text("UPLOAD")),
          ],
        ),
      ),
    );
  }
}