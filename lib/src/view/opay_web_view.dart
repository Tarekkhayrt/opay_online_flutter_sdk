// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:opay_online_flutter_sdk/src/model/web_js_response.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OPayWebView extends StatefulWidget {
  String webUrl;
  bool isLocalUrl;
  Function(WebJsResponse?)? backIconFunc;

  OPayWebView(
      {Key? key, this.webUrl = "", this.isLocalUrl = false, this.backIconFunc})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // ignore: no_logic_in_create_state
    return _OPayWebView();
  }
}

class _OPayWebView extends State<OPayWebView> {
  int _currentProgress = 0;
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _initializeWebViewController();
  }

  void _initializeWebViewController() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('clickResultOKBtn',
          onMessageReceived: (JavaScriptMessage message) async {
        String resultMsg = message.message;
        Map<String, dynamic> map = json.decode(resultMsg);
        WebJsResponse response = WebJsResponse.fromJson(map);
        _finishPage(response);
      })
      ..addJavaScriptChannel('clickResultCancelBtn',
          onMessageReceived: (JavaScriptMessage message) async {
        String resultMsg = message.message;
        Map<String, dynamic> map = json.decode(resultMsg);
        WebJsResponse response = WebJsResponse.fromJson(map);
        _finishPage(response);
      })
      ..addJavaScriptChannel('clickReferenceCodeReturnBtn',
          onMessageReceived: (JavaScriptMessage message) async {
        String resultMsg = message.message;
        Map<String, dynamic> map = json.decode(resultMsg);
        WebJsResponse response = WebJsResponse.fromJson(map);
        _finishPage(response);
      })
      ..enableZoom(false)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          debugPrint(request.url);
          if (!request.url.startsWith("http")) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onProgress: (int progress) {
          setState(() {
            _currentProgress = progress;
          });
        },
        onPageFinished: (String url) {
          debugPrint('Page finished loading: $url');
        },
      ));

    // Load the initial URL
    _webViewController.loadRequest(Uri.parse(widget.isLocalUrl
        ? Uri.dataFromString(widget.webUrl,
                mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
            .toString()
        : widget.webUrl));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: _buildBody());
  }

  Visibility _linearProgressIndicator() {
    return Visibility(
        visible: _currentProgress < 100,
        child: LinearProgressIndicator(
          value: _currentProgress / 100.0, // 当前进度
          backgroundColor: const Color(0xFFEEEEEE), // 进度条背景色
          valueColor:
              const AlwaysStoppedAnimation<Color>(Colors.red), // 进度条当前进度颜色
          minHeight: 4, // 最小宽度
        ));
  }

  _buildBody() {
    return Column(
      children: <Widget>[
        const SizedBox(
          height: 1,
          width: double.infinity,
          child:
              DecoratedBox(decoration: BoxDecoration(color: Color(0xFFEEEEEE))),
        ),
        _linearProgressIndicator(),
        Expanded(
          flex: 1,
          child: WebViewWidget(controller: _webViewController),
        ),
      ],
    );
  }

  _finishPage(WebJsResponse? webJsResponse) {
    if (widget.backIconFunc != null) {
      widget.backIconFunc!(webJsResponse);
    }
  }
}
