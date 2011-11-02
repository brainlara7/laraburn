callbackData = []
styles = {normal: "burnbit_normal", compact: "burnbit_compact"}

hasClass = (tag, name) ->
  tag.className.match(new RegExp("(\\s|^)" + name + "(\\s|$)"))

addClass = (tag, name) ->
  tag.className += " #{name}" unless hasClass(tag, name)

fillDetails = (tag, seeds, peers) ->
  tag.innerHTML = "<span class='burnbit_button_text' style='line-height:1;'>torrent</span> <span class='burnbit_torrent_details'><span class='s burnbit_seeds'>#{seeds} seeds</span><span class='p burnbit_peers'>#{peers} peers</span></span>"

finalize = (alive, href, seeds, peers) ->
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

  for req, n in callbackData
    a = document.createElement('script')
    a.src = "http://api.burnbit.com/getTorrent?#{req.queries.join('&')}&callback=#{makeCallback(n)}"
    document.body.appendChild(a)

  return undefined

oldOnLoad = window.onload
window.onload = ->
  oldOnLoad?()

  css = "n.burnbit_normal{height:30px;width:112px;padding-left:24px;padding-top:2px;}.burnbit_normal{display:block;text-align:left;background:#fff url(http://api.burnbit.com/images/button/down.png) no-repeat left 3px fixed;font-size:17px;}.burnbit_normal .burnbit_torrent_details{display:block;line-height:1;font-weight:700;font-size:9px;width:100%;}.burnbit_normal .burnbit_button_text{display:block;}a.burnbit_compact{background-color:#FFF;font-family:arial;text-decoration:none;border:none;color:#444;height:17px;width:160px;padding-left:16px;}.burnbit_compact{display:block;text-align:left;background:#fff url(http://api.burnbit.com/images/button/downcompact.png) no-repeat left 1px;line-height:11px;font-size:15px;}.burnbit_compact .burnbit_torrent_details{line-height:18px;font-weight:700;font-size:9px;width:100%;}.burnbit_torrent_details span.s{color:#6a902a;}.burnbit_torrent_details span.p{padding-left:2px;color:#787777;}a.burnbit_normal:hover,a.burnbit_compact:hover{text-decoration:none;}"
  style = document.createElement("style")
  style.setAttribute("type", "text/css")
  if style.styleSheet
    style.styleSheet.cssText = css
  else
    style.appendChild(document.createTextNode(css))
  document.getElementsByTagName('head')[0].appendChild(style)

  request()