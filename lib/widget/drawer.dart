import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:temple/routes/route_helper.dart';
import 'package:temple/screens/circulars_page.dart';
import 'package:temple/screens/splash_screen.dart';
import 'package:temple/utils/colors.dart';
import 'package:temple/utils/dimensions.dart';
import 'package:temple/widget/big_text.dart';
import 'package:temple/widget/show_custom_snakbar.dart';
import 'package:temple/widget/small_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';


class CustomeDrawer extends StatefulWidget {
  @override
  State<CustomeDrawer> createState() => _CustomeDrawerState();
}

class _CustomeDrawerState extends State<CustomeDrawer> {
  // bool isLoading = false;
  // ListResult? result;
  @override
  void initState() {
    super.initState();
    () async {
      checkInternetConnection();
    }();
  }

  String selectedItem = '2018-2019';

  final RxBool _hasInternet = false.obs;
  Future checkInternetConnection() async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      setState(() {
        _hasInternet(false);
      });
    } else {
      setState(() {
        _hasInternet(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: Dimensions.screenWidth / 1.26,
      backgroundColor: const Color.fromRGBO(225, 220, 219, 1),
      child: ListView(children: [
        DrawerHeader(
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BigText(
                    text: "FERTILIZER",
                    size: Dimensions.font26,
                  ),
                  BigText(
                    text: "TOWNSHIP ",
                    overFlow: TextOverflow.ellipsis,
                    size: Dimensions.font26,
                    color: AppColors.yellowColor,
                  ),
                ],
              ),
              SmallText(
                text: 'CHARITABLE TRUST',
                size: Dimensions.font20,
              ),
            ],
          ),
        ),
        ListTile(
          title: BigText(text: "Home"),
          leading: const Icon(Icons.home),
          onTap: (() {
            Get.back();
            Get.toNamed(RouteHelper.getInitial());
          }),
        ),
        ListTile(
          title: BigText(text: "About US"),
          leading: const Icon(Icons.temple_hindu_sharp),
          onTap: (() {
            Get.toNamed(RouteHelper.getAboutUsPage());
          }),
        ),
        ListTile(
          title: BigText(text: "Gallery"),
          leading: const Icon(Icons.image),
          onTap: (() {
            Get.toNamed(RouteHelper.getGalleryPage());
          }),
        ),
        ListTile(
          title: BigText(text: "Donate"),
          leading: const Icon(Icons.attach_money),
          onTap: (() {
            Get.toNamed(RouteHelper.getDonationPage());
          }),
        ),
        ListTile(
          title: BigText(text: "Book A Pooja"),
          leading: const Icon(Icons.bookmarks),
          onTap: (() {
            Get.toNamed(RouteHelper.getSlotBookPage());
          }),
        ),
        ListTile(
          title: BigText(text: "Contact US"),
          leading: const Icon(Icons.call),
          onTap: (() {
            Get.toNamed(RouteHelper.getContactUsPage());
          }),
        ),
        ListTile(
          title: BigText(text: "Circulars"),
          leading: const Icon(Icons.pages),
          onTap: (() {
            Get.toNamed(RouteHelper.getCircularPage());
          }),
        ),
        Divider(
          height: 1,
          thickness: 2,
        ),
        Container(
          margin: EdgeInsets.only(top: Dimensions.height15),
          padding: EdgeInsets.only(left: Dimensions.width45 / 2.5),
          height: Dimensions.height10 * 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.money,
                    color: Colors.black45,
                  ),
                  SizedBox(width: Dimensions.width30),
                  BigText(
                    text: "Expenses",
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    DropdownButton<String>(
                        hint: Text("......"),
                        borderRadius: BorderRadius.circular(10),

                        // elevation: 0,
                        iconSize: Dimensions.iconSize16 * 3,
                        items: items
                            .map((item) => DropdownMenuItem(
                                value: item, child: Text(item)))
                            .toList(),
                        onChanged: (item) async {
                          await checkInternetConnection();
                          if (_hasInternet == true) {
                            print(item.toString());
                            setState(() {
                              selectedItem = item!;
                              openFile(fileName: '$item.pdf');
                            });
                          } else {
                            showCustomSnakBar("Please Turn on Your Internet",
                                title: "Attention");
                          }
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 2,
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: TextButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
            ),
            child: SmallText(
              text: 'Upload Expanses',
              size: Dimensions.font16,
            ),
            onPressed: (() async {
              if (_hasInternet == true) {
                final path = await FlutterDocumentPicker.openDocument();
                if (path != null) {
                  File file = File(path);
                  UploadTask? task = await uploadFile(file);
                  Navigator.pop(context);
                }
              } else {
                showCustomSnakBar("Please Turn on Your Internet",
                    title: "Attention");
              }
            }),
          ),
        ),
        SizedBox(height: Dimensions.height30),
      ]),
    );
  }

  Future openFile({required String fileName}) async {
    try {
      var status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        print('Permission not granted');
        return;
      }

      showLoaderDialog(context, 'Loading...');
      final file = await downloadFile(fileName);
      if (file == null) return;
      print("path:${file.path}");

      final result = await OpenFile.open(
        file.path,
        type: "application/pdf",
      );

      // Check the result of the open operation
      print('Open file result: ${result.type}, ${result.message}');
    } on Exception catch (e) {
      print(e.toString());
      debugPrint("error" + e.toString());
    }
  }

  // Future<void> listExample() async {
  //   result = await FirebaseStorage.instance
  //       .ref()
  //       .child('files')
  //       .listAll();

  //   result?.items.forEach((Reference ref) {
  //     print('Found file: ${ref.fullPath}');
  //   });

  //   result?.prefixes.forEach((Reference ref) {
  //     print('Found directory: ${ref.fullPath}');
  //   });
  // }

  Future<File?> downloadFile(String name) async {
    String url =
        await FirebaseStorage.instance.ref('files/$name').getDownloadURL();
    print("url:$url");
    final appStorage = await getApplicationDocumentsDirectory();
    final file = File('${appStorage.path}/$name');
    print("file:$file");
    try {
      final response = await Dio().get(url,
          options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              receiveTimeout: Duration(seconds: 30)));

      Navigator.pop(context);
      final raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();

      return file;
    } catch (e) {
      print(e.toString());
      debugPrint("error" + e.toString());
      return null;
    }
  }


  Future<UploadTask?> uploadFile(File file) async {
    // showLoaderDialog(context, "Uploading...");
    UploadTask uploadTask;

    // Create a Reference to the file
    Reference ref = FirebaseStorage.instance.ref().child('files/').child(
        '/${(file.path).replaceAll('/data/user/0/com.example.temple/cache/', '')}');

    final metadata = SettableMetadata(
        contentType: 'file/pdf',
        customMetadata: {'picked-file-path': file.path});
    print("Uploading..!");

    uploadTask = ref.putData(await file.readAsBytes(), metadata);

    print("done..!");
    // Navigator.pop(context);

    return Future.value(uploadTask);
  }

  // List<String> items = ['2018-2019'];
  // void putPdfNameInItem() {
  //   items.clear();
  //   result?.items.forEach((Reference ref) {
  //     items.add((ref.name).replaceAll('.pdf', ''));
  //   });
  //   print(items);
  //   // isLoading = false;
  // }
}
