(function() {
  var addClass, callbackData, fillDetails, finalize, hasClass, makeCallback, oldOnLoad, request, styles;
  callbackData = [];
  styles = {
    normal: "burnbit_normal",
    compact: "burnbit_compact"
  };
  hasClass = function(tag, name) {
    return tag.className.match(new RegExp("(\\s|^)" + name + "(\\s|$)"));
  };
  addClass = function(tag, name) {
    if (!hasClass(tag, name)) {
      return tag.className += " " + name;
    }
  };
  fillDetails = function(tag, seeds, peers) {
    return tag.innerHTML = "<span class='burnbit_button_text' style='line-height:1;'>torrent</span> <span class='burnbit_torrent_details'><span class='s burnbit_seeds'>" + seeds + " seeds</span><span class='p burnbit_peers'>" + peers + " peers</span></span>";
  };
  finalize = function(alive, href, seeds, peers) {
    var bbstyle, styleKey, styleValue;
    console.debug({
      "this": this,
      alive: alive,
      href: href,
      seeds: seeds,
      peers: peers
    });
    if (this.torrentified != null) {
      return;
    }
    bbstyle = this.getAttribute('burnbit_style');
    this.href = href;
    this.torrentified = true;
    if (bbstyle != null) {
      bbstyle = bbstyle.toLowerCase();
      if (bbstyle.indexOf('custom') >= 0) {
        return;
      }
      for (styleKey in styles) {
        styleValue = styles[styleKey];
        if (bbstyle.indexOf(styleKey) >= 0) {
          addClass(this, styleValue);
          fillDetails(this, seeds, peers);
          return;
        }
      }
    }
    addClass(this, 'burnbit_normal');
    fillDetails(this, seeds, peers);
  };
  makeCallback = function(n) {
    var name;
    name = "burnBitRender" + n;
    window[name] = function(torrents) {
      var m, torrent, _len;
      for (m = 0, _len = torrents.length; m < _len; m++) {
        torrent = torrents[m];
        finalize.apply(callbackData[n].tags[m], torrent);
      }
      return delete window[name];
    };
    return name;
  };
  request = function() {
    var a, bytes, callback, n, queries, query, req, tag, torrentId, torrents, url, urls, _i, _j, _k, _len, _len2, _len3, _len4, _ref;
    torrents = (function() {
      var _len, _ref, _results;
      _ref = document.getElementsByClassName('burnbit_torrent');
      _results = [];
      for (torrentId = 0, _len = _ref.length; torrentId < _len; torrentId++) {
        tag = _ref[torrentId];
        urls = tag.getAttribute('burnbit_file').split('|');
        _results.push([
          tag, (function() {
            var _i, _len2, _results2;
            _results2 = [];
            for (_i = 0, _len2 = urls.length; _i < _len2; _i++) {
              url = urls[_i];
              _results2.push("u[" + torrentId + "][]=" + (escape(url)));
            }
            return _results2;
          })()
        ]);
      }
      return _results;
    })();
    callback = {
      tags: [],
      bytes: 0,
      queries: []
    };
    callbackData.push(callback);
    for (_i = 0, _len = torrents.length; _i < _len; _i++) {
      _ref = torrents[_i], tag = _ref[0], queries = _ref[1];
      bytes = 0;
      for (_j = 0, _len2 = queries.length; _j < _len2; _j++) {
        query = queries[_j];
        bytes += query.length + 1;
      }
      if (bytes < 1600) {
        if ((callback.bytes + bytes) >= 1600 || callback.tags.length >= 20) {
          callback = {
            tags: [],
            bytes: 0,
            queries: []
          };
          callbackData.push(callback);
        }
        callback.tags.push(tag);
        callback.bytes += bytes;
        for (_k = 0, _len3 = queries.length; _k < _len3; _k++) {
          query = queries[_k];
          callback.queries.push(query);
        }
      }
    }
    console.debug(callbackData);
    for (n = 0, _len4 = callbackData.length; n < _len4; n++) {
      req = callbackData[n];
      a = document.createElement('script');
      a.src = "http://api.burnbit.com/getTorrent?" + (req.queries.join('&')) + "&callback=" + (makeCallback(n));
      document.body.appendChild(a);
    }
  };
  oldOnLoad = window.onload;
  window.onload = function() {
    var a, b, c, d, e, style;
    if (typeof oldOnLoad === "function") {
      oldOnLoad();
    }
    a = "background-color: #FFF; font-family: arial; text-decoration: none; border: none; color: #444;";
    b = "display: block; text-align: left;";
    c = "font-weight: bold; font-size: 9px; width: 100%;";
    d = " .burnbit_torrent_details span.s { color: #6a902a; } .burnbit_torrent_details span.p { padding-left: 2px; color: #787777; }";
    e = "n.burnbit_normal { " + a + " height: 30px; width: 112px; padding-left: 24px; padding-top: 2px; }  a.burnbit_normal:hover { text-decoration: none; }   .burnbit_normal { " + b + "  background-image: url('http://api.burnbit.com/images/button/down.png'); background-repeat: no-repeat; background-position: left 3px; font-size: 17px;}   .burnbit_normal .burnbit_torrent_details { display: block; line-height: 1; " + c + " } .burnbit_normal .burnbit_button_text { display: block; }";
    e += "a.burnbit_compact { " + a + " height: 17px; width: 160px; padding-left: 16px ;}  a.burnbit_compact:hover { text-decoration: none; } .burnbit_compact { " + b + "  background-image: url('http://api.burnbit.com/images/button/downcompact.png'); background-repeat: no-repeat; background-position: left 1px;  line-height: 11px; font-size: 15px;} .burnbit_compact .burnbit_torrent_details { line-height: 18px; " + c + "}";
    style = document.createElement("style");
    style.setAttribute("type", "text/css");
    if (style.styleSheet) {
      style.styleSheet.cssText = e + d;
    } else {
      style.appendChild(document.createTextNode(e + d));
    }
    document.getElementsByTagName('head')[0].appendChild(style);
    return request();
  };
}).call(this);