#= require simple_web_rtc

class @RoomShow
  constructor: (options) ->
    @_setStatus('waiting')
    @room = options.room
    @participation = options.participationId

    @_bindDom()

    @webrtc = new SimpleWebRTC
      localVideoEl: 'localVideo'
      remoteVideosEl: ''
      autoRequestMedia: true
      debug: false
      detectSpeakingEvents: true
      autoAdjustMic: false
      nick: options.nick

    @webrtc.on 'readyToCall', =>
      @webrtc.joinRoom @room if @room

    @webrtc.on 'channelMessage', (peer, label, data) =>
      if data.type == 'volume'
        @showVolume document.getElementById('volume_' + peer.id), data.volume

    @webrtc.on 'videoAdded', (video, peer) =>
      @otherPeer = peer
      remote = document.getElementById('remote')
      if remote
        d = document.createElement('div')
        d.className = 'videoContainer'
        d.id = 'container_' + @webrtc.getDomId(peer)
        d.appendChild video
        vol = document.createElement('div')
        vol.id = 'volume_' + peer.id
        vol.className = 'volume_bar'

        video.onclick = ->
          video.style.width = video.videoWidth + 'px'
          video.style.height = video.videoHeight + 'px'

        d.appendChild vol
        remote.appendChild d
      $('#end-conversation').show()
      @_setStatus('chatting')

    @webrtc.on 'videoRemoved', (video, peer) =>
      @removeVideo(video, peer)

    @webrtc.on 'volumeChange', (volume, treshold) =>
      @showVolume document.getElementById('localVolume'), volume

  removeVideo: (video, peer) =>
    remote = document.getElementById('remote')
    el = document.getElementById('container_' + @webrtc.getDomId(peer))
    if remote and el
      remote.removeChild el
    $('.rating').show()
    $('#end-conversation').hide()
    @_setStatus('ending')

  showVolume: (el, volume) ->
    return unless el
    if volume < -45
      el.style.height = '0px'
    else if volume > -20
      el.style.height = '100%'
    else
      el.style.height = '' + Math.floor((volume + 100) * 100 / 25 - 220) + '%'

  _bindDom: ->
    window.onbeforeunload = ->
      $.ajax(url: "/participations/#{options.participationId}", type: 'DELETE')
      return undefined

    $ratingForm = $("#new_rating")
    $ratingForm.on "ajax:success", (e, data, status, xhr) ->
      $('.rating').hide()
      $('.new-buttons').show()
    $ratingForm.on "ajax:error", (e, xhr, status, error) ->
      $('.rating').hide()
      $('.new-buttons').show()

    $('#end-conversation').on 'click', =>
      $('#end-conversation').hide()
      @webrtc.leaveRoom()
      @webrtc.connection.disconnect()

    $('#toggle-local').on 'click', @_toggleLocal

  _setStatus: (status) ->
    status = switch status
      when 'waiting'
        'Waiting for someone to chat with'
      when 'chatting'
        "You are chatting with #{@otherPeer.nick}"
      when 'ending'
        "Your conversation with #{@otherPeer.nick} has ended"
      else
        ""
    $('.status').text(status)

  _toggleLocal: ->
    $toggleLocal = $('#toggle-local')
    if $toggleLocal.text() == '-'
      $('#localVideo').hide()
      $toggleLocal.text('+')
    else
      $('#localVideo').show()
      $toggleLocal.text('-')

