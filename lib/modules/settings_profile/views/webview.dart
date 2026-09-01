import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MyWebView extends StatelessWidget {
  const MyWebView({super.key, required this.url});

  final String url;

  Future<ServerTrustAuthResponse> _onReceivedServerTrustAuthRequest(
      InAppWebViewController controller,
      URLAuthenticationChallenge challenge) async {
    return ServerTrustAuthResponse(
        action: ServerTrustAuthResponseAction.PROCEED);
  }

  FutureOr<bool> _launchURL(String uri) async {
    try {
      String newUri = uri;
      if (uri.startsWith('intent')) {
        newUri = uri.replaceFirst('intent', 'https');
      }
      await launchUrlString(
        newUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e, s) {
      if (kDebugMode) {
        print(e);
        print(s);
      }
    }
    return false;
  }

  Future<NavigationActionPolicy> _shouldOverrideUrlLoading(
      InAppWebViewController controller,
      NavigationAction shouldOverrideUrlLoadingRequest) async {
    var uri = shouldOverrideUrlLoadingRequest.request.url;
    if (uri == null) {
      return NavigationActionPolicy.CANCEL;
    }
    final uriString = uri.toString();
    if (uriString.startsWith('http://') || uriString.startsWith('https://')) {
      return NavigationActionPolicy.ALLOW;
    } else {
      _launchURL(uriString);
      return NavigationActionPolicy.CANCEL;
    }
  }

  Future<bool> _onCreateWindow(
      InAppWebViewController controller, CreateWindowAction action) async {
    var uri = action.request.url;
    if (uri == null) {
      return false;
    }
    final uriString = uri.toString();
    if (uriString.startsWith('http://') || uriString.startsWith('https://')) {
      return true;
    } else {
      _launchURL(uriString);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(url)),
          onCreateWindow: _onCreateWindow,
          shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
          onReceivedServerTrustAuthRequest: _onReceivedServerTrustAuthRequest,
          initialSettings: InAppWebViewSettings(
            useShouldOverrideUrlLoading: true,
            javaScriptEnabled: true,
            useHybridComposition: true,
            allowsInlineMediaPlayback: true,
          ),
        ),
      ),
    );
  }
}
