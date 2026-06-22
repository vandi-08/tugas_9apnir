import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class UploadFotoPage extends StatefulWidget {
  final dynamic userId;

  const UploadFotoPage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<UploadFotoPage> createState() =>
      _UploadFotoPageState();
}

class _UploadFotoPageState
    extends State<UploadFotoPage> {
  XFile? _pickedXFile;
  Uint8List? _webImage;

  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  Future<void> _pickImage(
    ImageSource source,
  ) async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final bytes =
            await pickedFile.readAsBytes();

        setState(() {
          _pickedXFile = pickedFile;
          _webImage = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Gagal mengambil gambar: $e",
          ),
        ),
      );
    }
  }

  Future<void> _uploadImage() async {
    if (_pickedXFile == null ||
        _webImage == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Silakan pilih gambar terlebih dahulu",
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var request =
          http.MultipartRequest(
        "POST",
        Uri.parse(
          "http://localhost/flutter_api/user/upload_image.php",
        ),
      );

      request.fields["id"] =
          widget.userId.toString();

      request.files.add(
        http.MultipartFile.fromBytes(
          "image",
          _webImage!,
          filename:
              _pickedXFile!.name,
        ),
      );

      var streamedResponse =
          await request.send();

      var response =
          await http.Response.fromStream(
        streamedResponse,
      );

      var data =
          jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["status"] ==
              "success") {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content:
                Text(data["message"]),
            backgroundColor:
                Colors.green,
          ),
        );

        Navigator.pop(
          context,
          true,
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              data["message"] ??
                  "Gagal upload gambar",
            ),
            backgroundColor:
                Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Terjadi kesalahan: $e",
          ),
          backgroundColor:
              Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Upload Foto Profil",
        ),
        backgroundColor:
            const Color(
          0xff4A43EC,
        ),
        foregroundColor:
            Colors.white,
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,
          children: [
            Center(
              child: CircleAvatar(
                radius: 80,
                backgroundColor:
                    Colors.grey[300],
                backgroundImage:
                    _webImage != null
                        ? MemoryImage(
                            _webImage!,
                          )
                        : null,
                child:
                    _webImage == null
                        ? const Icon(
                            Icons.person,
                            size: 80,
                            color:
                                Colors.grey,
                          )
                        : null,
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .center,
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      _pickImage(
                    ImageSource
                        .camera,
                  ),
                  icon: const Icon(
                    Icons.camera_alt,
                  ),
                  label: const Text(
                    "Kamera",
                  ),
                ),

                const SizedBox(
                  width: 15,
                ),

                ElevatedButton.icon(
                  onPressed: () =>
                      _pickImage(
                    ImageSource
                        .gallery,
                  ),
                  icon: const Icon(
                    Icons.photo_library,
                  ),
                  label: const Text(
                    "Galeri",
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 40,
            ),

            SizedBox(
              width:
                  double.infinity,
              height: 50,
              child:
                  ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : _uploadImage,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            "Simpan ke Server",
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}