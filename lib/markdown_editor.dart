library markdown_editor;

import 'package:flutter/material.dart';
import 'package:markdown_core/builder.dart';
import 'package:markdown_editor/action.dart';
import 'package:markdown_editor/editor.dart';
import 'package:markdown_editor/preview.dart';

class MarkdownText {
  const MarkdownText(this.title, this.text);

  final String title;
  final String text;
}

enum PageType { editor, preview }

class MarkdownEditor extends StatefulWidget {
  MarkdownEditor({
    Key key,
    this.padding = const EdgeInsets.all(0.0),
    this.initTitle,
    this.initText,
    this.hintTitle,
    this.hintText,
    this.onTapLink,
    this.imageSelect,
    this.tabChange,
    this.textChange,
    this.actionIconColor = Colors.grey,
    this.cursorColor,
    this.titleTextStyle,
    this.textStyle,
    this.appendBottomWidget,
    this.maxWidth,
    this.imageWidget,
  }) : super(key: key);

  final EdgeInsetsGeometry padding;
  final String initTitle;
  final String initText;
  final String hintTitle;
  final String hintText;

  /// see [MdPreview.onTapLink]
  final TapLinkCallback onTapLink;

  /// see [ImageSelectCallback]
  final ImageSelectCallback imageSelect;

  /// When page change to [PageType.preview] or [PageType.editor]
  final TabChange tabChange;

  /// When title or text changed
  final ValueChanged<String> textChange;

  /// Change icon color, eg: color of font_bold icon.
  final Color actionIconColor;

  final Color cursorColor;

  final TextStyle titleTextStyle;
  final TextStyle textStyle;

  final Widget appendBottomWidget;

  final double maxWidth;
  final WidgetImage imageWidget;

  @override
  State<StatefulWidget> createState() => MarkdownEditorWidgetState();
}

class MarkdownEditorWidgetState extends State<MarkdownEditor>
    with SingleTickerProviderStateMixin {
  final GlobalKey<MdEditorState> _editorKey = GlobalKey();
  TabController _controller;
  String _previewText = '';

  /// Get edited Markdown title and text
  MarkdownText getMarkDownText() {
    return MarkdownText(
        _editorKey.currentState.getTitle(), _editorKey.currentState.getText());
  }

  /// Change current [PageType]
  void setCurrentPage(PageType type) {
    _controller.index = type.index;
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: PageType.values.length);
    _controller.addListener(() {
      if (_controller.index == PageType.preview.index) {
        setState(() {
          _previewText = _editorKey.currentState.getText();
        });
      }
      if (widget.tabChange != null) {
        widget.tabChange(_controller.index == PageType.editor.index
            ? PageType.editor
            : PageType.preview);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
        //     TabBar(
        //       controller: _controller,
        //       tabs: [
        //         Tab(
        //           text: 'Editor',
        //         ),
        //         Tab(icon: 'Preview'),
        //       ],
        //     ),
        // Padding(
        //   padding: EdgeInsets.all(5),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Text(
        //         '${_controller.index != PageType.preview.index ? 'Editor' : 'Viewer'}',
        //         style: TextStyle(fontSize: 17),
        //       ),
        //       ElevatedButton(
        //           onPressed: () {
        //             setState(() {
        //               if (_controller.index == PageType.preview.index) {
        //                 setCurrentPage(PageType.editor);
        //               } else {
        //                 setCurrentPage(PageType.preview);
        //               }
        //             });
        //           },
        //           child: Text(
        //               'Toggle ${_controller.index == PageType.preview.index ? 'Edit' : 'Preview'}')),
        //     ],
        //   ),
        // ),
        Scaffold(
                  appBar: AppBar(
          bottom: TabBar(
            controller: _controller,
            tabs: [
              Tab(
                text: 'Editor',
              ),
              Tab(text: 'Preview'),
            ],
          ),
          title: Text('Editor'),
        ),
        body: TabBarView(
          controller: _controller,
          children: <Widget>[
            SafeArea(
              child: MdEditor(
                key: _editorKey,
                padding: widget.padding,
                initText: widget.initText,
                initTitle: widget.initTitle,
                hintText: widget.hintText,
                hintTitle: widget.hintTitle,
                titleStyle: widget.titleTextStyle,
                textStyle: widget.textStyle,
                imageSelect: widget.imageSelect,
                textChange: widget.textChange,
                actionIconColor: widget.actionIconColor,
                cursorColor: widget.cursorColor,
                appendBottomWidget: widget.appendBottomWidget,
              ),
            ),
            SafeArea(
              child: MdPreview(
                text: _previewText,
                padding: widget.padding,
                onTapLink: widget.onTapLink,
                maxWidth: widget.maxWidth,
                widgetImage: widget.imageWidget,
              ),
            ),
          ],
        ),
      );
  }
}

typedef void TabChange(PageType type);
