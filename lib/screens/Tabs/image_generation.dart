import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:gala_gatherings/api_service.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageGeneration extends StatefulWidget {
  @override
  _ImageGenerationState createState() => _ImageGenerationState();
}

class _ImageGenerationState extends State<ImageGeneration> {
  final TextEditingController _promptController = TextEditingController();
  bool _isLoading = false;
  Uint8List? _imageData;
  List<String> _recentPrompts = [];
  @override
  void initState() {
    super.initState();
    _loadRecentPrompts();
  }

  Future<void> _loadRecentPrompts() async {
    final prefs = await SharedPreferences.getInstance();

    // Get the existing list of prompts from SharedPreferences
    List<String>? recentPrompts = prefs.getStringList('bellyIMAGING_prompts');

    if (recentPrompts != null) {
      setState(() {
        _recentPrompts = recentPrompts;
      });
    }
  }

  Future<void> savePrompt(String prompt) async {
    final prefs = await SharedPreferences.getInstance();

    // Get the existing list of prompts from SharedPreferences
    List<String> promptsList =
        prefs.getStringList('bellyIMAGING_prompts') ?? [];

    // Check if the prompt already exists in the list
    if (!promptsList.contains(prompt)) {
      // Append the new prompt to the list only if it doesn't exist
      promptsList.add(prompt);
    }

    // Save the updated list back to SharedPreferences
    await prefs.setStringList('bellyIMAGING_prompts', promptsList);
  }

  Future<void> _askBellyAI() async {
    print("Button clicked");

    setState(() {
      _isLoading = true;
      _imageData = null; // Clear previous image
    });

    SystemChannels.textInput.invokeMethod('TextInput.hide');

    final prompt = _promptController.text.trim();
    print("Prompt: $prompt");

    if (prompt.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    savePrompt(prompt);
    try {
      final response = await Provider.of<Auth>(context, listen: false)
          .bellyAiTextToImage(prompt);

      if (response != null) {
        setState(() {
          _imageData = response;
        });
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _askBellyAIForRecent(prompt) async {
    print("Button clicked");

    setState(() {
      _isLoading = true;
      _imageData = null; // Clear previous image
    });

    print("Prompt: $prompt");

    if (prompt.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await Provider.of<Auth>(context, listen: false)
          .bellyAiTextToImage(prompt);

      if (response != null) {
        setState(() {
          _imageData = response;
        });
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadImage() async {
    if (_imageData == null) return;

    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/generated_image.jpg';
      final File imageFile = File(filePath);
      await imageFile.writeAsBytes(_imageData!);
      final params = SaveFileDialogParams(sourceFilePath: filePath);
      final finalPath = await FlutterFileDialog.saveFile(params: params);

      if (finalPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to $filePath')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image not saved ')),
        );
      }
    } catch (e) {
      print('Error saving image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving image')),
      );
    }
  }

  void _showInputBottomSheet(BuildContext context) {
    print("_isLoading $_isLoading");
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius.only(
                  topLeft: SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
                  topRight: SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
                ),
              ),
            ),
            child: Wrap(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30,
                      height: 5,
                      decoration: ShapeDecoration(
                        color: Color(0xffFA6E00),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 15,
                            cornerSmoothing: 1,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '  Write your requirement here..',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff0A4C61),
                          fontFamily: 'Product Sans',
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _promptController,
                      style: TextStyle(
                        color: Color(0xff0A4C61),
                        height: 1.2,
                        fontSize: 20,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.bold,
                      ),
                      cursorColor: Color(0xff0A4C61),
                      maxLines: null,
                      decoration: InputDecoration(
                        hintMaxLines: 3,
                        hintStyle: TextStyle(
                          color: Color(0xff0A4C61).withOpacity(0.4),
                          height: 1.2,
                          fontSize: 20,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.bold,
                        ),
                        hintText: 'Describe the image you want to generate...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color(0xffD3EEEE).withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () {
                              if (FocusScope.of(context).hasFocus) {
                                SystemChannels.textInput
                                    .invokeMethod('TextInput.hide');
                              }

                              setState(() {
                                _isLoading = true;
                              });
                              Navigator.of(context).pop();

                              _askBellyAI();
                            },
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: ShapeDecoration(
                            shadows: [
                              BoxShadow(
                                offset: const Offset(5, 6),
                                color: Color(0xffFA6E00).withOpacity(0.51),
                                blurRadius: 30,
                              ),
                            ],
                            color: _isLoading ? Colors.grey : Color(0xffFA6E00),
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 15,
                                cornerSmoothing: 1,
                              ),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : Text(
                                  'Generate Image',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Product Sans',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffEFF9FB),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 30,
                          cornerSmoothing: 1,
                        ),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0xffA5C8C7).withOpacity(0.4),
                          blurRadius: 25,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: Image.asset(
                                'assets/images/back_double_arrow.png',
                                color: Color(0xffFA6E00),
                                width: 24,
                                height: 24,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'GG Imaging',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontFamily: 'Product Sans Black',
                                      letterSpacing: 1,
                                      color: Color(0xff0A4C61),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'GG’s text to image model',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Product Sans',
                                      // letterSpacing: 1,
                                      color: Color(0xff0A4C61),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        if (_isLoading)
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 50.h),
                                // Container(
                                //   constraints: BoxConstraints(maxWidth: 100.w),
                                //   child: Lottie.asset(
                                //     'assets/Animation - 1727950634187.json.json',
                                //     width: 100.w,
                                //   ),
                                // ),
                                Text(
                                  'Loading ...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Product Sans',
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    color: Color(0xff0A4C61),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (_imageData != null)
                          Column(
                            children: [
                              SizedBox(
                                height: 30,
                              ),
                              Container(
                                  constraints: BoxConstraints(maxWidth: 90.w),
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "“${_promptController.text.trim()}”",
                                    style: TextStyle(
                                        fontFamily: 'Product Sans',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff0A4C61)),
                                  )),
                              SizedBox(
                                height: 15,
                              ),
                              if (_imageData !=
                                  null) // Ensure image data is not null
                                Container(
                                  width: double.infinity,
                                  // height: MediaQuery.of(context).size.width *
                                  //     1, // Fixed height based on screen width
                                  decoration: ShapeDecoration(
                                    shadows: [
                                      BoxShadow(
                                        offset: const Offset(0, 3),
                                        color:
                                            Color(0xff1B7997).withOpacity(0.31),
                                        blurRadius: 30,
                                      ),
                                    ],
                                    color: Color(0xffFA6E00),
                                    shape: SmoothRectangleBorder(
                                      borderRadius: SmoothBorderRadius(
                                        cornerRadius: 40,
                                        cornerSmoothing: 1,
                                      ),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: SmoothBorderRadius(
                                      cornerRadius: 40,
                                      cornerSmoothing: 1,
                                    ),
                                    child: Image.memory(
                                      _imageData!,
                                      fit: BoxFit
                                          .cover, // Use BoxFit.cover to ensure the image fills the container
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.width * 0.75,
                                  color: Colors
                                      .grey[300], // Placeholder color or image
                                  child: Center(
                                    child: Text(
                                      'No Image Available',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _downloadImage,
                                icon: Icon(Icons.download_rounded),
                                label: Text(
                                  'Download',
                                  style: TextStyle(
                                      fontFamily: 'Product Sans',
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1),
                                ),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Color(0xffFA6E00),
                                  shape: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius(
                                      cornerRadius: 15,
                                      cornerSmoothing: 1,
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                ),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _shareImage(
                                      _imageData); // Call the async function within a synchronous function
                                },
                                icon: Icon(Icons.share),
                                label: Text('Share',
                                    style: TextStyle(
                                        fontFamily: 'Product Sans',
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1)),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Color(0xff0A4C61),
                                  shape: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius(
                                      cornerRadius: 15,
                                      cornerSmoothing: 1,
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                ),
                              ),
                            ],
                          )
                        else
                          Center(
                            child: _recentPrompts.isNotEmpty
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, // Aligns items to the start of the column
                                    children: [
                                      SizedBox(height: 10),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Recent',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontFamily:
                                                    'Product Sans Black',
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff0A4C61),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                var prefs =
                                                    await SharedPreferences
                                                        .getInstance();

                                                // Clear the list of prompts by saving an empty list
                                                await prefs.setStringList(
                                                    'bellyIMAGING_prompts', []);

                                                // Update the state to reflect the cleared list
                                                setState(() {
                                                  _recentPrompts = [];
                                                });
                                              },
                                              child: Text(
                                                'Clear',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: 'Product Sans',
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xff0A4C61),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                          height:
                                              10), // Add some space below the title
                                      Container(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children:
                                                _recentPrompts.map((prompt) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5.0,
                                                        horizontal: 10),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    // Set loading state regardless of keyboard status
                                                    setState(() {
                                                      _isLoading = true;
                                                    });

                                                    _askBellyAIForRecent(
                                                        prompt);
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 30,
                                                        height: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xffD1EBEE),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: Icon(
                                                          Icons
                                                              .refresh, // Use any suitable icon
                                                          color:
                                                              Color(0xff0A4C61),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width:
                                                              10), // Add space between the icon and text
                                                      Expanded(
                                                        child: Text(
                                                          prompt,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontFamily:
                                                                'Product Sans',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xff0A4C61),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(
                                    // constraints:
                                    //     BoxConstraints(minHeight: 60.h),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Container(
                                        //   child: Lottie.asset(
                                        //     'assets/Animation - 1727950634187.json.json',
                                        //     width: MediaQuery.of(context)
                                        //             .size
                                        //             .width *
                                        //         1,
                                        //         height: 10.h
                                        //   ),
                                        // ),
                                        SizedBox(height: 16),
                                        Center(
                                          child: Text(
                                            'You have not asked anything yet!.',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'Product Sans',
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff0A4C61),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showInputBottomSheet(context),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: ShapeDecoration(
                    shadows: [
                      BoxShadow(
                        offset: const Offset(5, 6),
                        color: Color(0xffFA6E00).withOpacity(0.51),
                        blurRadius: 30,
                      ),
                    ],
                    color: Color(0xffFA6E00),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 15,
                        cornerSmoothing: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    'Generate Image',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _shareImage(Uint8List? imageData) async {
  if (imageData == null) return;

  try {
    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/generated_image.jpg';
    final imageFile = File(imagePath);

    await imageFile.writeAsBytes(imageData);

    // await Share.shareFiles([imageFile.path],
    //     text:
    //         'Check out this image I generated using GG AI from GG . !');
  } catch (e) {
    print('Error sharing image: $e');
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Error sharing image')),
    // );
  }
}
