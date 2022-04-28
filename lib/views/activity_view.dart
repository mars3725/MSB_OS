import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:html';

class ActivityView extends StatefulWidget {
  const ActivityView({Key? key, required this.url}) : super(key: key);
  final String url;

  @override
  _ActivityViewState createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  final IFrameElement _iframeElement = IFrameElement();

  @override
  initState() {
    super.initState();

    _iframeElement.src = widget.url;
    _iframeElement.id = 'iframe';
    _iframeElement.style.border = 'none';
    _iframeElement.allowFullscreen = false;

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
        'iframeElement',
            (int viewId) => _iframeElement
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                  onPressed: ()=> Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white, size: 48)
              )
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(75),
              child: HtmlElementView(
                key: UniqueKey(),
                viewType: 'iframeElement',
              ),
            ),
          )
        ],
      ),
    );
  }
}