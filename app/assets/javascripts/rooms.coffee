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

        d.appendChild vol
        remote.insertBefore d, remote.firstChild

      video.style.width = '800px';

      $('.messages-container').append("<div class=\"from well well-sm bg-info\"></div>")
      $('.from:last').text("Hey! What's going on!?")

      @createChatDataChannel()
      @_bindChat()

      $('#send-message').removeClass('display-none')
      $('.toggle').removeClass('display-none')
      $('.control-buttons').removeClass('display-none')
      $('.no-user-container').addClass('display-none')
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
    $('.rating').removeClass('display-none')
    $('.control-buttons').addClass('display-none')
    @_setStatus('ending')
    $('#rate-other-user').append(document.createTextNode(' with ' + @otherPeer.nick))
    $('.videoContainer').remove()
    $('.remote-container').addClass('display-none')
    $('#send-message').addClass('display-none')
    @webrtc.leaveRoom()
    @webrtc.stopLocalVideo()

  showVolume: (el, volume) ->
    return unless el
    if volume < -45
      el.style.height = '0px'
    else if volume > -20
      el.style.height = '100%'
    else
      el.style.height = '' + Math.floor((volume + 100) * 100 / 25 - 220) + '%'

  recieveMessage: (message) ->
    $('.messages-container').append("<div class=\"from well well-sm bg-info\"></div>")
    $('.from:last').text(message)
    $('.messages-container').scrollTop($('.messages-container')[0].scrollHeight);

  sendMessage: (message) ->
    @webrtc.channel.send(JSON.stringify({type: 'chatMessage', chatMessage: message}))
    $('.messages-container').append("<div class=\"to well well-sm\"></div>")
    $('.to:last').text(message)
    $('.messages-container').scrollTop($('.messages-container')[0].scrollHeight);

  _bindChat: ->
    $sendMessage = $('#send-message')
    $sendMessage.prop('disabled', false)
    $sendMessage.keypress (e) =>
      if e.which == 13 && $sendMessage.val() != '' && e.shiftKey == false
        @sendMessage($sendMessage.val())
        $sendMessage.val('')
        return false;

  _bindDom: ->
    window.onbeforeunload = =>
      if @status == 'waiting'
        $.ajax(url: "/participations/#{@participation}", type: 'DELETE')
        return undefined
      else if @status == 'chatting'
        return 'Make sure to end your conversation before leaving!'
      else
        return undefined

    $ratingForm = $("#new_rating")
    $ratingForm.on "ajax:success", (e, data, status, xhr) ->
      $('.rating').addClass('display-none')
      $('.new-buttons').removeClass('display-none')
    $ratingForm.on "ajax:error", (e, xhr, status, error) ->
      $('.rating').addClass('display-none')
      $('.new-buttons').removeClass('display-none')

    $('#end-conversation').on 'click', =>
      $('#end-conversation').addClass('display-none')
      @webrtc.leaveRoom()
      @webrtc.connection.disconnect()

    $('#toggle-local').on 'click', @_toggleLocal
    $('#toggle-chat').on 'click', @_toggleChat

    @_controlButtons()

  _setStatus: (status) ->
    @status = status
    status = switch status
      when 'waiting'
        'Waiting for someone to chat with'
      when 'chatting'
        "You are chatting with #{@otherPeer.nick}"
      when 'ending'
        "Your conversation with #{@otherPeer.nick} has ended"
      else
        ""

    $('.status').text('')
    $('.status').append(document.createTextNode(status))

  _toggleLocal: ->
    $toggleLocal = $('#toggle-local span')
    if $toggleLocal.hasClass('glyphicon-menu-left')
      $toggleLocal.removeClass('glyphicon-menu-left')
      $toggleLocal.addClass('glyphicon-menu-right')
      $('.left-panel').hide()
    else
      $toggleLocal.removeClass('glyphicon-menu-right')
      $toggleLocal.addClass('glyphicon-menu-left')
      $('.left-panel').show()

  _toggleChat: ->
    $toggleChat = $('#toggle-chat span')
    if $toggleChat.hasClass('glyphicon-menu-right')
      $toggleChat.removeClass('glyphicon-menu-right')
      $toggleChat.addClass('glyphicon-menu-left')
      $('.chat-panel').addClass('display-none')
    else
      $toggleChat.removeClass('glyphicon-menu-left')
      $toggleChat.addClass('glyphicon-menu-right')
      $('.chat-panel').removeClass('display-none')

  _controlButtons: ->
    $('#mute-microphone-button').on 'click', @_toggleMic
    $('#mute-volume-button').on 'click', @_toggleVolume

  _toggleMic: =>
    $mic = $('#mute-microphone-button')
    if $mic.hasClass('btn-danger')
      @webrtc.unmute()
      @_toggleDanger($mic)
    else
      @webrtc.mute()
      @_toggleDanger($mic)

  _toggleVolume: =>
    $vol = $('#mute-volume-button')
    if $vol.hasClass('btn-danger')
      @webrtc.setVolumeForAll(1)
      @_toggleDanger($vol)
    else
      @webrtc.setVolumeForAll(0)
      @_toggleDanger($vol)

  _toggleDanger: ($el) ->
    $el.toggleClass('btn-danger')
    $el.toggleClass('btn-default')
