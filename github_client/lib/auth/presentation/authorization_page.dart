import 'dart:io';

import 'package:flutter/material.dart';
import 'package:github_client/auth/infrastructure/github_authenticator.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AuthorizationPage extends StatefulWidget {
  final Uri authorizationUrl;
  final void Function(Uri redirectUrl) onRedirectUrlAttempt;

  const AuthorizationPage({
    Key? key,
    required this.authorizationUrl,
    required this.onRedirectUrlAttempt,
  }) : super(key: key);

  @override
  State<AuthorizationPage> createState() => _AuthorizationPageState();
}

class _AuthorizationPageState extends State<AuthorizationPage> {
  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      WebView.platform = AndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: widget.authorizationUrl.toString(),
          navigationDelegate: (navReq) {
            if (navReq.url
                .startsWith(GithubAuthenticator.callbackUrl.toString())) {
              widget.onRedirectUrlAttempt(Uri.parse(navReq.url));
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebViewCreated: (controller) {
            controller.clearCache();
            CookieManager().clearCookies();
          },
        ),
      ),
    );
  }
}
