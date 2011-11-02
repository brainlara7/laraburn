callbackData = []
styles = {normal: "burnbit_normal", compact: "burnbit_compact"}

hasClass = (tag, name) ->
  tag.className.match(new RegExp("(\\s|^)" + name + "(\\s|$)"))

addClass = (tag, name) ->
  tag.className += " #{name}" unless hasClass(tag, name)

fillDetails = (tag, seeds, peers) ->
  tag.innerHTML = "<span class='burnbit_button_text' style='line-height:1;'>torrent</span> <span class='burnbit_torrent_details'><span class='s burnbit_seeds'>#{seeds} seeds</span><span class='p burnbit_peers'>#{peers} peers</span></span>"

finalize = (alive, href, seeds, peers) ->
  console.debug this: this, alive: alive, href: href, seeds: seeds, peers: peers
  return if @torrentified?
  bbstyle = @getAttribute('burnbit_style')
  @href = href
  @torrentified = true

  if bbstyle?
    bbstyle = bbstyle.toLowerCase()
    return if bbstyle.indexOf('custom') >= 0
    for styleKey, styleValue of styles
      if bbstyle.indexOf(styleKey) >= 0
        addClass(@, styleValue)
        fillDetails(@, seeds, peers)
        return undefined
  addClass(@, 'burnbit_normal')
  fillDetails(@, seeds, peers)
  return undefined

makeCallback = (n) ->
  name = "burnBitRender#{n}"

  window[name] = (torrents) ->
    for torrent, m in torrents
      finalize.apply(callbackData[n].tags[m], torrent)
    delete window[name]

  return name

request = ->
  torrents = for tag, torrentId in document.getElementsByClassName('burnbit_torrent')
    urls = tag.getAttribute('burnbit_file').split('|')
    [tag, ("u[#{torrentId}][]=#{escape(url)}" for url in urls)]

  callback = {tags: [], bytes: 0, queries: []}
  callbackData.push(callback)

  for [tag, queries] in torrents
    bytes = 0
    bytes += (query.length + 1) for query in queries
    if bytes < 1600
      if (callback.bytes + bytes) >= 1600 || callback.tags.length >= 20
        callback = {tags: [], bytes: 0, queries: []}
        callbackData.push(callback)
      callback.tags.push(tag)
      callback.bytes += bytes
      callback.queries.push(query) for query in queries

  console.debug(callbackData)

  for req, n in callbackData
    a = document.createElement('script')
    a.src = "http://api.burnbit.com/getTorrent?#{req.queries.join('&')}&callback=#{makeCallback(n)}"
    document.body.appendChild(a)

  return undefined

oldOnLoad = window.onload
window.onload = ->
  oldOnLoad?()

  a = "background-color: #FFF; font-family: arial; text-decoration: none; border: none; color: #444;"
  b = "display: block; text-align: left;"
  c = "font-weight: bold; font-size: 9px; width: 100%;"
  d = " .burnbit_torrent_details span.s { color: #6a902a; } .burnbit_torrent_details span.p { padding-left: 2px; color: #787777; }"
  e = "n.burnbit_normal { " + a + " height: 30px; width: 112px; padding-left: 24px; padding-top: 2px; }  a.burnbit_normal:hover { text-decoration: none; }   .burnbit_normal { " + b + "  background-image: url('http://api.burnbit.com/images/button/down.png'); background-repeat: no-repeat; background-position: left 3px; font-size: 17px;}   .burnbit_normal .burnbit_torrent_details { display: block; line-height: 1; " + c + " } .burnbit_normal .burnbit_button_text { display: block; }"
  e += "a.burnbit_compact { " + a + " height: 17px; width: 160px; padding-left: 16px ;}  a.burnbit_compact:hover { text-decoration: none; } .burnbit_compact { " + b + "  background-image: url('http://api.burnbit.com/images/button/downcompact.png'); background-repeat: no-repeat; background-position: left 1px;  line-height: 11px; font-size: 15px;} .burnbit_compact .burnbit_torrent_details { line-height: 18px; " + c + "}"

  style = document.createElement("style")
  style.setAttribute("type", "text/css")
  if style.styleSheet
    style.styleSheet.cssText = e + d
  else
    style.appendChild(document.createTextNode(e + d))
  document.getElementsByTagName('head')[0].appendChild(style)

  request()