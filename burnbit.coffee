torrents = {}
buffers = []
styles = {normal: "burnbit_normal", compact: "burnbit_compact"}

hasClass = (tag, name) ->
  tag.className.match(new RegExp("(\\s|^)" + name + "(\\s|$)"))

addClass = (tag, name) ->
  tag.className += " #{name}" unless hasClass(tag, name)

fillDetails = (tag, seeds, peers) ->
  tag.innerHTML = "<span class='burnbit_button_text' style='line-height:1;'>torrent</span> <span class='burnbit_torrent_details'><span class='s burnbit_seeds'>#{seeds} seeds</span><span class='p burnbit_peers'>#{peers} peers</span></span>"

finalize = (tag, seeds, peers) ->
  bbstyle = tag.getAttribute('burnbit_style')
  if bbstyle?
    bbstyle = bbstyle.toLowerCase()
    return if bbstyle.indexOf('custom') >= 0
    for styleKey, styleValue of styles
      if bbstyle.indexOf(styleKey) >= 0
        addClass(tag, styleValue)
        fillDetails(tag, seeds, peers)
        return undefined
  addClass(tag, 'burnbit_normal')
  fillDetails(tag, seeds, peers)
  return undefined

makeCallback = (n) ->
  name = "burnBitRender#{n}"
  window[name] = (infos) ->
    delete window[name]
    if buffer = buffers[n]
      for tag, m in buffer[2]
        console.debug infos[m]
        [alive, href, seeds, peers] = infos[m]

        tag.href = href
        finalize(tag, seeds, peers)

  return name

request = ->
  queries = []
  tags = []
  buffer = [0, queries, tags]
  buffers.push(buffer)

  for file, tag of torrents
    query = "u[#{queries.length}][]=#{escape(file)}"
    queryLength = query.length + 1

    if queryLength < 1600 # ignore any burnbit_file that's >= 1600
      if (buffer[0] + queryLength) >= 1600 || queries.length >= 20
        queries = []
        tags = []
        buffer = [0, queries, tags]
        buffers.push(buffer)

      queries.push(query)
      tags.push(tag)
      buffer[0] += queryLength

  for buffer, n in buffers
    if buffer[0] > 0
      a = document.createElement('script')
      a.src = "http://api.burnbit.com/getTorrent?#{buffer[1].join('&')}&callback=#{makeCallback(n)}"
      document.body.appendChild(a)
  undefined

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

  for tag in document.getElementsByClassName('burnbit_torrent')
    torrents[tag.getAttribute('burnbit_file')] = tag

  request()