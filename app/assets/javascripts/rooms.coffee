#= require ./channels/room-channel

class @RoomShow
  constructor: (options) ->
    @_setStatus('waiting')
    @room = options.room
    @participation = options.participationId
    @postId = options.postId
    @signalServer = options.signalServer

    @_bindDom()

    @webrtc = new SimpleWebRTC
      localVideoEl: 'localVideo'
      remoteVideosEl: ''
      autoRequestMedia: true
      debug: false
      detectSpeakingEvents: true
      autoAdjustMic: false
      nick: options.nick
      url: @signalServer

    @setupWebRTC()

  setupRecordRTC: ->
    options =
      type: 'video'
      frameInterval: 20

    window.recordRTC = RecordRTC(@webrtc.webrtc.localStreams[0], options)

    $('#react-button').click ->
      $('.reactions-and-react-button').addClass('display-none')
      $('.reaction-panel').append('<h1>You Are Reacting! Look at the camera!</h1>')

      recordRTC.startRecording()

      setTimeout(->
        recordRTC.stopRecording (videoURL) ->
          $('.reaction-panel h1').remove()
          $('.react-results-container').removeClass('display-none')
          $('.react-results-container').prepend("<video style=\"width:90%;\" autoplay=\"true\" src=\"#{videoURL}\"></video>")
      , 3000)

    $('#post-reaction').click =>
      $('.react-results-container').addClass('display-none')
      $('.reactions-and-react-button').removeClass('display-none')
      fd = new FormData();
      fd.append('post_id', $('.post-header')[0].id);
      fd.append('video', recordRTC.getBlob());
      $.post
        url: "/reactions",
        data: fd,
        processData: false,
        contentType: false,
        success: (data) =>
          window.addReaction($('.post-header')[0].id)

    $('#toss-reaction').click ->
      $('.react-results-container').addClass('display-none')
      $('.reactions-and-react-button').removeClass('display-none')
      $('.react-results-container video').remove()

  setupWebRTC: ->
    @webrtc.on 'readyToCall', =>
      @setupRecordRTC()
      $('#react-button').show()
      @webrtc.joinRoom @room if @room

    @webrtc.on 'channelMessage', (peer, label, data) =>
      if data.type == 'volume'
        @showVolume document.getElementById('volume_' + peer.id), data.volume

    @webrtc.on 'videoAdded', (video, peer) =>
      @otherPeer = peer
      remote = document.getElementById('remote')
      if remote
        d = document.createElement('div')
        d.className = 'videoContainer remote'
        d.id = 'container_' + @webrtc.getDomId(peer)
        d.appendChild video
        vol = document.createElement('div')
        vol.id = 'volume_' + peer.id
        vol.className = 'volume_bar'

        d.appendChild vol
        remote.insertBefore d, remote.firstChild

      document.getElementById('notification-sound').play()

      window.nextPost(@postId, firstPost: true)

      $('.control-buttons').removeClass('display-none')
      $('.no-user-container').addClass('display-none')
      $('#next-post').removeClass('display-none')

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
    $('.rating').removeClass('display-none')
    $('.control-buttons').addClass('display-none')
    @_setStatus('ending')
    $('#rate-other-user').append(document.createTextNode(' with ' + @otherPeer.nick))
    $('.videoContainer').remove()
    $('.remote-container').addClass('display-none')
    $('#send-message').addClass('display-none')
    $('.remote-panel').css('justify-content', 'flex-start')
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

  _bindDom: ->
    window.onbeforeunload = =>
      if @status == 'waiting'
        $.ajax(url: "/chat/#{@room}", type: 'PUT') # When you leave your own room and navigate back to front page, you should see num chating change becauce of you.
        return undefined
      else
      if @status == 'chatting'
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

    $('#next-post').on 'click', =>
      $('#next-post').tooltip('disable')

    $('button').on 'click', ->
      $(this).blur()

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
