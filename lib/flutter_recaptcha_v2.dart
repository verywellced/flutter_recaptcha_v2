library flutter_recaptcha_v2;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class RecaptchaV2 extends StatefulWidget {
  final String apiKey;
  final String apiSecret;
  final String pluginURL;
  final RecaptchaV2Controller controller;
  final bool visibleCancelBottom;
  final bool hideOnVerify;
  final String textCancelButtom;
  final Color webViewBgColor;

  final ValueChanged<bool>? onVerifiedSuccessfully;
  final ValueChanged<String>? onVerifiedError;
  final ValueChanged<String>? onSendToken;

  RecaptchaV2({
    required this.apiKey,
    required this.apiSecret,
    this.pluginURL = "https://recaptcha-flutter-plugin.firebaseapp.com/",
    this.visibleCancelBottom = false,
    this.textCancelButtom = "CANCEL CAPTCHA",
    RecaptchaV2Controller? controller,
    this.onVerifiedSuccessfully,
    this.onSendToken,
    this.onVerifiedError,
    this.hideOnVerify = true,
    this.webViewBgColor = Colors.white,
  }) : controller = controller ?? RecaptchaV2Controller();

  @override
  State<StatefulWidget> createState() => _RecaptchaV2State();
}

class _RecaptchaV2State extends State<RecaptchaV2> {
  late RecaptchaV2Controller controller;
  WebViewController? webViewController;

  void verifyToken(String token) async {
    if (token.isNotEmpty) {
      widget.onVerifiedSuccessfully!(true);
      widget.onSendToken!(token);
    } else {
      widget.onVerifiedSuccessfully!(false);
    }

    // hide captcha
    if (widget.hideOnVerify) {
      controller.hide();
    }
  }

  void onListen() {
    if (controller.visible) {
      if (webViewController != null) {
        //webViewController!.clearCache();
        //webViewController!.reload();
      }
    }
    if (this.mounted) {
      setState(() {
        controller.visible;
      });
    }
  }

  @override
  void initState() {
    controller = widget.controller;
    controller.addListener(onListen);
    super.initState();
  }

  @override
  void didUpdateWidget(RecaptchaV2 oldWidget) {
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(onListen);
      controller = widget.controller;
      controller.removeListener(onListen);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    //controller.removeListener(onListen);
    //controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return controller.visible
        ? Stack(
            children: <Widget>[
              WebView(
                initialUrl: "${widget.pluginURL}?api_key=${widget.apiKey}",
                javascriptMode: JavascriptMode.unrestricted,
                backgroundColor: widget.webViewBgColor,
                javascriptChannels: <JavascriptChannel>[
                  JavascriptChannel(
                    name: 'RecaptchaFlutterChannel',
                    onMessageReceived: (JavascriptMessage receiver) {
                      String _token = receiver.message;
                      if (_token.contains("verify")) {
                        _token = _token.substring(7);
                      }
                      verifyToken(_token);
                    },
                  ),
                ].toSet(),
                onWebViewCreated: (_controller) {
                  webViewController = _controller;
                },
              ),
              Visibility(
                visible: widget.visibleCancelBottom,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 60,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                          child: ElevatedButton(
                            child: Text(widget.textCancelButtom),
                            onPressed: () {
                              controller.hide();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        : Container();
  }
}

class RecaptchaV2Controller extends ChangeNotifier {
  bool isDisposed = false;
  List<VoidCallback> _listeners = [];

  bool _visible = false;
  bool get visible => _visible;

  void show() {
    _visible = true;
    if (!isDisposed) notifyListeners();
  }

  void hide() {
    _visible = false;
    if (!isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    //_listeners = [];
    //isDisposed = true;
    super.dispose();
  }

  @override
  void addListener(listener) {
    _listeners.add(listener);
    super.addListener(listener);
  }

  @override
  void removeListener(listener) {
    //_listeners.remove(listener);
    super.removeListener(listener);
  }
}
