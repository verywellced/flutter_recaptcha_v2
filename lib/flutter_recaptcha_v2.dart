library flutter_recaptcha_v2;

import 'package:flutter/material.dart';
import 'package:flutter_recaptcha_v2/controller/recaptchav2_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RecaptchaV2 extends StatefulWidget {
  final String apiKey;
  final String apiSecret;
  final String pluginURL;
  final RecaptchaV2Controller recaptchaController;
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
    RecaptchaV2Controller? recaptchaController,
    this.onVerifiedSuccessfully,
    this.onSendToken,
    this.onVerifiedError,
    this.hideOnVerify = true,
    this.webViewBgColor = Colors.white,
  }) : recaptchaController = recaptchaController ?? RecaptchaV2Controller();

  @override
  State<StatefulWidget> createState() => _RecaptchaV2State();
}

class _RecaptchaV2State extends State<RecaptchaV2> {
  late RecaptchaV2Controller recaptchaController;
  late final WebViewController webViewController;

  @override
  void initState() {
    recaptchaController = widget.recaptchaController;
    recaptchaController.addListener(onListen);
    _initializeController();

    super.initState();
  }

  void _initializeController() {
    webViewController = WebViewController()
      ..loadRequest(Uri.parse("${widget.pluginURL}?api_key=${widget.apiKey}"))
      ..addJavaScriptChannel('RecaptchaFlutterChannel',
          onMessageReceived: (JavaScriptMessage receiver) {
        String _token = receiver.message;
        if (_token.contains("verify")) {
          _token = _token.substring(7);
        }
        verifyToken(_token);
      })
      ..setBackgroundColor(widget.webViewBgColor)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
  }

  @override
  void didUpdateWidget(RecaptchaV2 oldWidget) {
    if (widget.recaptchaController != oldWidget.recaptchaController) {
      oldWidget.recaptchaController.removeListener(onListen);
      recaptchaController = widget.recaptchaController;
      recaptchaController.removeListener(onListen);
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
    return recaptchaController.visible
        ? Stack(
            children: <Widget>[
              WebViewWidget(controller: webViewController),
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
                              recaptchaController.hide();
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

  void verifyToken(String token) async {
    if (token.isNotEmpty) {
      widget.onVerifiedSuccessfully!(true);
      widget.onSendToken!(token);
    } else {
      widget.onVerifiedSuccessfully!(false);
    }

    // hide captcha
    if (widget.hideOnVerify) {
      recaptchaController.hide();
    }
  }

  void onListen() {
    if (recaptchaController.visible) {
      if (webViewController != null) {
        //webViewController!.clearCache();
        //webViewController!.reload();
      }
    }
    if (this.mounted) {
      setState(() {
        recaptchaController.visible;
      });
    }
  }
}
