import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wechat_timeline_post/widgets/appBar.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class GalleryWidget extends StatefulWidget {
  const GalleryWidget(
      {super.key,
      required this.initialIndex,
      required this.items,
      this.isBarVisible});

//初始化图片位置
  final int initialIndex;
//图片列表
  final List<AssetEntity> items;
//是否显示bar
  final bool? isBarVisible;

  @override
  State<GalleryWidget> createState() => _GalleryWidgetState();
}

class _GalleryWidgetState extends State<GalleryWidget>
    with SingleTickerProviderStateMixin {
  bool visible = true;

  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    visible = widget.isBarVisible ?? true;
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  Widget _mainView() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          visible = !visible;
        });
        // Navigator.pop(context);
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: _buildImageView(),
        backgroundColor: Colors.black,
        appBar: SlideAppBarWidget(
          controller: controller,
          visible: visible,
          child: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        ),
      ),
    );
  }

  Widget _buildImageView() {
    return ExtendedImageGesturePageView.builder(
      controller: ExtendedPageController(initialPage: widget.initialIndex),
      itemCount: widget.items.length,
      itemBuilder: (BuildContext context, int index) {
        var item = widget.items[index];

        return ExtendedImage(
            image: AssetEntityImageProvider(item, isOriginal: true),
            fit: BoxFit.contain,
            mode: ExtendedImageMode.gesture,
            initGestureConfigHandler: ((state) {
              return GestureConfig();
            }));
      },
      scrollDirection: Axis.horizontal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _mainView();
  }
}
