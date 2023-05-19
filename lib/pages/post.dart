import 'package:flutter/material.dart';
import 'package:flutter_wechat_timeline_post/widgets/gallery.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../utils/config.dart';

class PostEditPage extends StatefulWidget {
  const PostEditPage(String s, {super.key});

  @override
  State<PostEditPage> createState() => _PostEditPageState();
}

class _PostEditPageState extends State<PostEditPage> {
  //选中图片列表
  List<AssetEntity> _selectedAsssets = [];

  //是否正在拖拽
  bool isDraging = false;
  //是否将要删除
  bool isWillRemove = false;

//图片列表
  Widget _buildPhotoList() {
    return Padding(
      padding: const EdgeInsets.all(spacing),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          var width = (constraints.maxWidth - spacing * 2) / 3;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              ..._selectedAsssets
                  .map((e) => _buildPhotoItem(e, width))
                  .toList(),
              if (_selectedAsssets.length < 9) _buildAddbutton(width),
            ],
          );
        },
      ),
    );
  }

  GestureDetector _buildAddbutton(double width) {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        color: Colors.black38,
        width: width,
        height: width,
        child: const Icon(
          Icons.add,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildPhotoItem(AssetEntity e, double width) {
    return Draggable(
      data: e,
      //开始拖动
      onDragStarted: () => setState(() {
        isDraging = true;
      }),
      //拖动结束
      onDragEnd: (details) => setState(() {
        isDraging = false;
      }),
      //当dargable被放置到[DragTarget]接受时调用
      onDragCompleted: () => setState(() {
        // isWillRemove = true;
      }),
      //当dargable取消放置到[DragTarget]接受时调用
      onDraggableCanceled: (velocity, offset) => setState(() {
        isDraging = false;
      }),
      feedback: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
        child: AssetEntityImage(
          e,
          width: width,
          height: width,
          fit: BoxFit.cover,
          isOriginal: false,
        ),
      ),
      childWhenDragging: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
        child: AssetEntityImage(
          e,
          width: width,
          height: width,
          fit: BoxFit.cover,
          isOriginal: false,
          opacity: const AlwaysStoppedAnimation(0.5),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return GalleryWidget(
                initialIndex: _selectedAsssets.indexOf(e),
                items: _selectedAsssets);
          }));
        },
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
          child: AssetEntityImage(
            e,
            width: width,
            height: width,
            fit: BoxFit.cover,
            isOriginal: false,
          ),
        ),
      ),
    );
  }

  //底部删除区域
  Widget _buildRemoveView() {
    return DragTarget(
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: double.infinity,
          height: 130,
          color: isWillRemove ? Colors.red[300] : Colors.red[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.delete,
                size: 32,
                color: isWillRemove ? Colors.white : Colors.white70,
              ),
              Container(height: spacing),
              Text(
                '拖动到此处删除',
                style: TextStyle(
                    color: isWillRemove ? Colors.white : Colors.white70),
              ),
            ],
          ),
        );
      },
      onWillAccept: (data) {
        setState(() {
          isWillRemove = true;
        });
        return true;
      },
      onAccept: (data) {
        setState(() {
          _selectedAsssets.remove(data);
          isWillRemove = false;
        });
      },
      onLeave: (data) {
        setState(() {
          isWillRemove = false;
        });
      },
    );
  }

  //添加方法
  _onTap() async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(context);
    print(result?.length);
    if (result == null) return;

    setState(() {
      _selectedAsssets = result;
    });
  }

  //主视图
  Widget _mainView() {
    return Column(
      children: [
        _buildPhotoList(),
        // const Spacer(),
        // isDraging ? _buildRemoveView() : SizedBox.shrink(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _mainView(),
      appBar: AppBar(title: const Text('发布')),
      bottomSheet: isDraging ? _buildRemoveView() : null,
    );
  }
}
