class ProxyConfig {
  static const String httpUrl =
      'https://raw.githubusercontent.com/islam885/voxy/main/proxies/http.txt';
  static const String socks4Url =
      'https://raw.githubusercontent.com/islam885/voxy/main/proxies/socks4.txt';
  static const String socks5Url =
      'https://raw.githubusercontent.com/islam885/voxy/main/proxies/socks5.txt';

  static String getUrlForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'socks4':
        return socks4Url;
      case 'socks5':
        return socks5Url;
      case 'http':
      default:
        return httpUrl;
    }
  }
}

