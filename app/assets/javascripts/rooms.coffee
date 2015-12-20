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
    $('.toggle').hide()

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

      @createChatDataChannel()
      @_bindChat()

      $('#send-message').show()
      $('.toggle').show()
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
    $('#rate-other-user').append(document.createTextNode(' with ' + @otherPeer.nick))
    $('.videoContainer').remove()
    $('.remote-container').hide()


  showVolume: (el, volume) ->
    return unless el
    if volume < -45
      el.style.height = '0px'
    else if volume > -20
      el.style.height = '100%'
    else
      el.style.height = '' + Math.floor((volume + 100) * 100 / 25 - 220) + '%'

  recieveMessage: (message) ->
    $('.messages-container').append("<div class=\"from well well-sm bg-info\">#{message}</div>")

  sendMessage: (message) ->
    console.log('hi')
    @webrtc.channel.send(JSON.stringify({type: 'chatMessage', chatMessage: message}))
    $('.messages-container').append("<div class=\"to well well-sm\">#{message}</div>")

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
      $('.chat-panel').hide()
    else
      $toggleChat.removeClass('glyphicon-menu-left')
      $toggleChat.addClass('glyphicon-menu-right')
      $('.chat-panel').show()
