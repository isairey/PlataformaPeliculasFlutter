import 'package:webview_flutter/webview_flutter.dart';

class AdBlocker {
  static const List<String> _blockedDomains = [
    'doubleclick.net', 'googlesyndication.com', 'googleadservices.com',
    'pagead2.googlesyndication.com', 'adcolony.com', 'applovin.com',
    'vungle.com', 'chartboost.com', 'admob.com', 'connect.facebook.net',
    'adnxs.com', 'adsrvr.org', 'advertising.com', 'media.net',
    'outbrain.com', 'taboola.com', 'revcontent.com', 'bidswitch.net',
    'rubiconproject.com', 'openx.net', 'pubmatic.com', 'criteo.com',
    'amazon-adsystem.com', 'moatads.com', 'adsafeprotected.com',
    'scorecardresearch.com', 'quantserve.com', 'bluekai.com',
    'casalemedia.com', 'contextweb.com', 'appnexus.com', 'lijit.com',
    'sharethrough.com', 'spotxchange.com', 'teads.tv', 'yieldmo.com',
    'triplelift.com', 'indexexchange.com', 'sovrn.com', 'smaato.com',
    'tradedoubler.com', 'awinmedia.com', 'popcash.net', 'popads.net',
    'propellerads.com', 'hilltopads.net', 'juicyads.com', 'exoclick.com',
    'trafficjunky.com', 'adspyglass.com', 'mgid.com', 'smartadserver.com',
    'adform.net', 'adzerk.net', 'yieldlab.net', 'adhigh.net',
    'google-analytics.com', 'googletagmanager.com', 'googletagservices.com',
    'mixpanel.com', 'segment.io', 'amplitude.com', 'hotjar.com',
    'coinzilla.io', 'a-ads.com', 'adtng.com', 'adf.ly',
    'rtmark.net', 'discsrelated.shop', 'metrics',
  ];

  static bool shouldBlock(String url) {
    try {
      final host = Uri.parse(url).host.toLowerCase();
      for (final domain in _blockedDomains) {
        if (host == domain || host.endsWith('.$domain')) return true;
      }
    } catch (_) {}
    return false;
  }

  static NavigationDecision filterNavigation(
    NavigationRequest request,
    String embedHost,
  ) {
    final url = request.url.toLowerCase();
    if (url.contains(embedHost)) return NavigationDecision.navigate;
    if (url.startsWith('blob:') || url.startsWith('data:')) return NavigationDecision.navigate;
    if (!url.startsWith('http')) return NavigationDecision.prevent;
    if (shouldBlock(url)) return NavigationDecision.prevent;
    return NavigationDecision.navigate;
  }

  static String get earlyJsInjection => '''
    (function() {
      try {
        var style = document.createElement('style');
        style.type = 'text/css';
        style.innerHTML = 'iframe[src*="1xbet"], iframe[src*="betway"], iframe[src*="doubleclick"], iframe[src*="taboola"], iframe[src*="outbrain"], iframe[src*="exoclick"], iframe[src*="turnhub"], div[style*="z-index: 2147483647"], div[style*="z-index: 999999"], div[style*="position: fixed"] { pointer-events: none !important; display: none !important; opacity: 0 !important; visibility: hidden !important; }';
        document.documentElement.appendChild(style);
      } catch (e) {}

      var _open = window.open;
      window.open = function() { return null; };
      Object.defineProperty(window, 'onbeforeunload', {
        set: function() {},
        get: function() { return null; }
      });
      document.addEventListener('click', function(e) {
        var t = e.target;
        while (t && t !== document.documentElement && t !== document.body) {
          if (t.tagName === 'A') {
            var href = t.getAttribute('href') || '';
            if (t.target === '_blank' || (href.indexOf('http') === 0 && href.indexOf(window.location.hostname) === -1)) {
              e.preventDefault();
              t.removeAttribute('href');
              t.removeAttribute('target');
            }
            break;
          }
          t = t.parentNode;
        }
      }, true);

      var originalFetch = window.fetch;
      window.fetch = function() {
        var arg = arguments[0];
        var url = typeof arg === 'string' ? arg : (arg && arg.url ? arg.url : '');
        if (url && (url.indexOf('rtmark.net') !== -1 || url.indexOf('metrics') !== -1 || url.indexOf('discsrelated') !== -1)) {
          return Promise.resolve(new Response('{}', { status: 200, statusText: 'OK' }));
        }
        return originalFetch.apply(this, arguments);
      };

      var originalXhrOpen = XMLHttpRequest.prototype.open;
      XMLHttpRequest.prototype.open = function(method, url) {
        if (typeof url === 'string' && (url.indexOf('rtmark.net') !== -1 || url.indexOf('metrics') !== -1 || url.indexOf('discsrelated') !== -1)) {
          url = 'data:application/json,{}';
        }
        return originalXhrOpen.apply(this, arguments);
      };
    })();
  ''';

  static String get domCleanerJs => '''
    (function() {
      window.open = function() { return null; };
      var blockedHosts = ['doubleclick.net','googlesyndication.com','adnxs.com','taboola.com','outbrain.com','exoclick.com','trafficjunky.com','popads.net','popcash.net','adspyglass.com','juicyads.com','propellerads.com','1xbet','betway','bet365','betting','discsrelated.shop'];

      function isAdHost(src) {
        if (!src) return false;
        try {
          var urlStr = src.toLowerCase();
          return blockedHosts.some(function(d) { return urlStr.indexOf(d) !== -1; });
        } catch(e) { return false; }
      }

      function isVideoRelated(el) {
        var id = (el.id || '').toLowerCase();
        var cls = (typeof el.className === 'string' ? el.className : '').toLowerCase();
        var tag = el.tagName || '';
        if (tag === 'VIDEO' || id === 'player') return true;
        if (cls.indexOf('plyr') !== -1 || cls.indexOf('jw-') !== -1 || cls.indexOf('vjs') !== -1 || cls.indexOf('video') !== -1) return true;
        return false;
      }

      function removeEl(el) {
        try { el.parentNode && el.parentNode.removeChild(el); } catch(e) {}
      }

      function cleanDOM() {
        document.querySelectorAll('iframe').forEach(function(el) {
          if (isVideoRelated(el)) return;
          if (isAdHost(el.src || el.getAttribute('src'))) removeEl(el);
          var style = window.getComputedStyle(el);
          if (style.position === 'absolute' || style.position === 'fixed') {
            if (parseInt(style.zIndex || '0', 10) > 900) removeEl(el);
          }
        });
        document.querySelectorAll('div').forEach(function(el) {
          if (isVideoRelated(el)) return;
          var style = window.getComputedStyle(el);
          if ((style.position === 'absolute' || style.position === 'fixed') && parseInt(style.zIndex || '0', 10) > 900) {
            removeEl(el);
          }
        });
        document.querySelectorAll('script[src]').forEach(function(el) {
          if (isAdHost(el.getAttribute('src'))) removeEl(el);
        });
        document.querySelectorAll('a').forEach(function(el) {
          var txt = (el.textContent || '').toLowerCase();
          if (txt.indexOf('verify') !== -1 && txt.indexOf('human') !== -1) removeEl(el);
          if (txt.indexOf('1xbet') !== -1 || txt.indexOf('bet') !== -1) removeEl(el);
          if (el.target === '_blank') el.removeAttribute('target');
        });
      }

      var timer;
      new MutationObserver(function(mutations) {
        clearTimeout(timer);
        timer = setTimeout(cleanDOM, 800);
      }).observe(document.documentElement, { childList: true, subtree: true });

      setInterval(cleanDOM, 2000);
      cleanDOM();
    })();
  ''';
}
