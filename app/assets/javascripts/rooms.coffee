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

    @setupWebRTC()

  setupWebRTC: ->
    @webrtc.on 'readyToCall', =>
      @webrtc.joinRoom @room if @room

    @webrtc.on 'channelMessage', (peer, label, data) =>
      if data.type == 'volume'
        @showVolume document.getElementById('volume_' + peer.id), data.volume
      if data.type == 'chatMessage'
        @recieveMessage(data['chatMessage'])

        console.log(data, label)

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

      @createChatDataChannel()
      @_bindChat()

      $('#end-conversation').show()
      @_setStatus('chatting')

    @webrtc.on 'videoRemoved', (video, peer) =>
      @removeVideo(video, peer)

    @webrtc.on 'volumeChange', (volume, treshold) =>
      @showVolume document.getElementById('localVolume'), volume

  createChatDataChannel: ->
    pc = @webrtc.webrtc.peers[0].pc
    @webrtc.channel = pc.createDataChannel("ChatData");

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

  recieveMessage: (message) ->
    $('.messages-continer').append("<div class=\"from\">#{message}</div>")

  sendMessage: (message) ->
    @webrtc.channel.send(JSON.stringify({type: 'chatMessage', chatMessage: message}))
    $('.messages-continer').append("<div class=\"to\">#{message}</div>")

  _bindChat: ->
    $sendMessage = $('#send-message')
    $sendMessage.prop('disabled', false)
    $sendMessage.keypress (e) =>
      if e.which == 13 && $sendMessage.val() != '' && e.shiftKey == false
        @sendMessage($sendMessage.val())
        $sendMessage.val('')
        return false;

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
    $('#toggle-chat').on 'click', @_toggleChat

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
    $toggleLocal = $('#toggle-local span')
    if $toggleLocal.hasClass('glyphicon-indent-right')
      $toggleLocal.removeClass('glyphicon-indent-right')
      $toggleLocal.addClass('glyphicon-indent-left')
      $('.left-panel').hide()
    else
      $toggleLocal.removeClass('glyphicon-indent-left')
      $toggleLocal.addClass('glyphicon-indent-right')
      $('.left-panel').show()

  _toggleChat: ->
    $toggleChat = $('#toggle-chat span')
    if $toggleChat.hasClass('glyphicon-indent-left')
      $toggleChat.removeClass('glyphicon-indent-left')
      $toggleChat.addClass('glyphicon-indent-right')
      $('.chat-panel').hide()
    else
      $toggleChat.removeClass('glyphicon-indent-right')
      $toggleChat.addClass('glyphicon-indent-left')
      $('.chat-panel').show()
