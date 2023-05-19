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
  //是否将要排序
  bool isWillSort = false;
  //拖拽排序时被拖拽到的target id
  String targetAssetId = '';

//图片列表
  Widget _buildPhotoList() {
    return Padding(
      padding: const EdgeInsets.all(spacing),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          var width = (constraints.maxWidth -
                  spacing * 2 -
                  imageBorderWidth * 2 * columnCount) /
              columnCount;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              ..._selectedAsssets
                  .map((e) => _buildPhotoItem(e, width))
                  .toList(),
              if (_selectedAsssets.length < maxAssets) _buildAddbutton(width),
            ],
          );
        },
      ),
    );
  }

  GestureDetector _buildAddbutton(double width) {
    return GestureDetector(
      onTap: _onTap,
      child: Padding(
        padding: const EdgeInsets.all(imageBorderWidth),
        child: Container(
          decoration:
              BoxDecoration(color: Colors.black12, borderRadius: radius),
          width: width,
          height: width,
          child: const Icon(Icons.add, size: 48),
        ),
      ),
    );
  }

  Widget _buildPhotoItem(AssetEntity asset, double width) {
    return Draggable(
      data: asset,
      //开始拖动
      onDragStarted: () => setState(() {
        isDraging = true;
      }),
      //拖动结束
      onDragEnd: (details) => setState(() {
        isDraging = false;
        isWillSort = false;
      }),
      // //当dargable被放置到[DragTarget]接受时调用
      // onDragCompleted: () => setState(() {
      //   // isWillRemove = true;
      // }),
      // //当dargable取消放置到[DragTarget]接受时调用
      onDraggableCanceled: (velocity, offset) => setState(() {
        isDraging = false;
        isWillSort = false;
      }),
      feedback: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: radius),
        child: AssetEntityImage(
          asset,
          width: width,
          height: width,
          fit: BoxFit.cover,
          isOriginal: false,
        ),
      ),
      childWhenDragging: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: radius,
          border:
              Border.all(width: imageBorderWidth, color: Colors.transparent),
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: radius),
          child: AssetEntityImage(
            asset,
            width: width,
            height: width,
            fit: BoxFit.cover,
            isOriginal: false,
            opacity: const AlwaysStoppedAnimation(0.5),
          ),
        ),
      ),
      child: DragTarget(
        builder: (context, candidateData, rejectedData) {
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return GalleryWidget(
                    initialIndex: _selectedAsssets.indexOf(asset),
                    items: _selectedAsssets);
              }));
            },
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(
                      color: (isWillSort && targetAssetId == asset.id)
                          ? accentColor
                          : Colors.transparent,
                      width: imageBorderWidth)),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(borderRadius: radius),
                child: AssetEntityImage(
                  asset,
                  width: width,
                  height: width,
                  fit: BoxFit.cover,
                  isOriginal: false,
                ),
              ),
            ),
          );
        },
        onWillAccept: (data) {
          setState(() {
            isWillSort = true;
            targetAssetId = asset.id;
          });
          return true;
        },
        onAccept: (data) {
          //从队列中删除target
          final int index = _selectedAsssets.indexOf(data as AssetEntity);
          _selectedAsssets.removeAt(index);
          //将拖拽对象插入到目标之前
          final targetIndex = _selectedAsssets.indexOf(asset);
          _selectedAsssets.insert(targetIndex, data);

          setState(() {
            isWillSort = false;
            targetAssetId = '';
          });
        },
        onLeave: (data) {
          setState(() {
            isWillSort = false;
            targetAssetId = '';
          });
        },
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
    final List<AssetEntity>? result = await AssetPicker.pickAssets(context,
            pickerConfig: AssetPickerConfig(
                maxAssets: 9, selectedAssets: _selectedAsssets))
        .then((value) {
      print('执行回调');
      print(value);
    });
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
