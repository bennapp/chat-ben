#= require ./channels/room-channel

class @RoomShow
  constructor: (options) ->
    @nick = currentUser.name
    @room = options.room
    @mobile = options.mobile
    @signalServer = options.signalServer
    @_setStatusWithLight()
    @reacting = false

    @_bindDom()

  onReactMousedown: ->
    return unless forceSignIn(event)
    @reacting = true
    successCallback = (stream) =>
      options = { type: 'video', frameInterval: 20 }
      @reactStream = stream
      window.recordRTC = RecordRTC(stream, options)

      video = document.querySelector('#reaction-preview')
      if window.URL
        video.src = window.URL.createObjectURL(stream)
      else
        video.src = stream
      video.play()

      @mouseup = false
      @isHold = false
      @isTimeOut = false

      $('#reaction-preview').removeClass('display-none')
      $('.reactions-and-react-button').addClass('display-none')
      $('.reaction-panel').append('<div class="glow-container"><span class="red-glow"></span><h2> You Are Reacting!</h2></div>')
      recordRTC.startRecording()

      setTimeout(=>
        @isHold = !@mouseup
      , 1000)

      setTimeout(=>
        if !@isHold
          recordRTC.stopRecording @stopRecordingRTC
      , 4000)

      setTimeout(=>
        @isTimeOut = !@mouseup
        if @isTimeOut
          recordRTC.stopRecording @stopRecordingRTC
      , 10000)

    errorCallback = (error) =>
      @stopRecordingRTC()
      console.log 'navigator.getUserMedia error: ', error

    navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia
    navigator.getUserMedia({ audio: true, video: true }, successCallback, errorCallback)

  stopRecordingRTC: (videoURL) =>
    @reacting = false
    @reactStream.getTracks()[0].stop() if @reactStream
    @reactStream.getTracks()[1].stop() if @reactStream
    $('.reaction-panel .glow-container').remove()
    $('.react-results-container video').remove()
    $('.react-results-container').removeClass('display-none')
    $('.react-results-container').prepend("<video style=\"width:90%;\" autoplay=\"true\" src=\"#{videoURL}\"></video>") if videoURL
    $('#reaction-preview').addClass('display-none')

  removeVideo: (video, peer) =>
    remote = document.getElementById('remote')
    el = document.getElementById('container_' + @webrtc.getDomId(peer))
    if remote and el
      remote.removeChild el

    $('.control-buttons').addClass('hidden')
    $('.chat-again-container').removeClass('hidden')
    @_setStatus('ending')
    $('.remote-container').addClass('invisible')
    $('#localVideo').addClass('invisible')

    @stopWebRTC()

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
      if @status == 'chatting'
        return 'Make sure to end your conversation before leaving!'
      else
        return undefined

    $('#end-conversation').on 'click', =>
      @webrtc.leaveRoom()
      @webrtc.connection.disconnect()

    $('#next-post').on 'click', =>
      $('#next-post').tooltip('disable')

    $('button').on 'click', ->
      $(this).blur()

    $('#react-button').show()
    @setupRecordRTCDom()

    @_controlButtons()
    @_newPostButton()
    @_matchingSwitch()

  _setStatus: (status) ->
    @status = status
    window.status = status
    status = switch status
      when 'not-waiting'
        'Video Chat is disabled'
      when 'waiting'
        'Waiting for someone to chat with'
      when 'friends'
        'Invite friends to watch together!'
      when 'chatting'
        "You are chatting with #{@otherPeer.nick || 'someone'}"
      when 'ending'
        "Your conversation with #{@otherPeer.nick || 'someone'} has ended"
      else
        ""

    $('.status').text('')
    $('.status').append(document.createTextNode(status))

  _matchingSwitch: ->
    setLight = (event) =>
      $('.on').removeClass('on')
      $target = $(event.target)
      if $target.hasClass('party')
        $('.party').addClass('on')
        window.matchingSwtich('party')
        if @status != 'chatting' && @status != 'ending'
          window.resize()
          @_setStatus('waiting')
          @_startWebRTC()

      else if $target.hasClass('friends')
        $('.friends').addClass('on')
        window.matchingSwtich('friends')
        if @status != 'chatting' && @status != 'ending'
          window.resize()
          @_setStatus('friends')
          @_startWebRTC()

      else if $target.hasClass('solo')
        $('.solo').addClass('on')
        window.matchingSwtich('solo')
        if @status != 'chatting' && @status != 'ending'
          @stopWebRTC()
          @_setStatus('not-waiting')
          $('.chat-info-container').addClass('hidden')
          $('.local-video-container').addClass('hidden')
          $('.remote-container').addClass('hidden')
          window.resize()
      else
        console.log('else')

    $('.light').on 'click', setLight
    $('.stoplight-option').on 'click', setLight

  _setStatusWithLight: ->
    $light = $('.light.on')
    if $light.hasClass('party') && !@mobile
      @_setStatus('waiting')
      @_startWebRTC()
    else if $light.hasClass('friends') && !@mobile
      @_setStatus('friends')
      @_startWebRTC()
    else
      @_setStatus('not-waiting')
      $('.chat-info-container').addClass('hidden')
      $('.local-video-container').addClass('hidden')
      $('.remote-container').addClass('hidden')

  stopWebRTC: ->
    @webrtc.stopLocalVideo()

  _startWebRTC: ->
    $('.chat-info-container').removeClass('hidden')
    $('.local-video-container').removeClass('hidden')
    $('.remote-container').removeClass('hidden')

    startWebRTC = =>
      if @webrtc
        @webrtc.startLocalVideo() unless @webrtc.webrtc.localStreams.length
      else
        @webrtc = new window.SimpleWebRTC
          localVideoEl: 'localVideo'
          remoteVideosEl: ''
          autoRequestMedia: true
          debug: false
          detectSpeakingEvents: true
          autoAdjustMic: false
          nick: @nick
          url: @signalServer

        @webrtc.on 'readyToCall', =>
          @webrtc.joinRoom @room

        @webrtc.on 'channelMessage', (peer, label, data) =>
          if data.type == 'volume'
            @showVolume document.getElementById('volume_' + peer.id), data.volume

        @webrtc.on 'videoAdded', (video, peer) =>
          window.resize()
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

          $('.control-buttons').removeClass('invisible')
          $('.no-user-container').addClass('hidden')

          @_setStatus('chatting')

        @webrtc.on 'videoRemoved', (video, peer) =>
          window.resize()
          @removeVideo(video, peer)

        @webrtc.on 'volumeChange', (volume, treshold) =>
          @showVolume document.getElementById('localVolume'), volume

    setTimeout(startWebRTC, 400)

  setupRecordRTCDom: ->
    $('#react-button').mousedown =>
      @onReactMousedown()

    $('#react-button').bind 'mouseup', =>
      return unless forceSignIn(event)
      if @reactStream && @reacting
        @mouseup = true
        $('#react-button').addClass('display-none')
        if @isHold && !@isTimeOut
          recordRTC.stopRecording @stopRecordingRTC

    $('#react-button').bind 'mouseleave', =>
      if @reactStream && @reacting
        @mouseup = true
        $('#react-button').addClass('display-none')
        if @isHold && !@isTimeOut
          recordRTC.stopRecording @stopRecordingRTC

    $('#post-reaction').click =>
      $('.react-results-container').addClass('display-none')
      $('.reactions-and-react-button').removeClass('display-none')
      $('#react-button').removeClass('display-none')
      fd = new FormData();
      fd.append('post_id', $('.post-header').data('post-id'));
      fd.append('video', recordRTC.getBlob());
      $.post
        url: "/reactions",
        data: fd,
        processData: false,
        contentType: false,
        success: (data) =>
          window.addReaction($('.post-header').data('post-id'))
          recordRTC.clearRecordedData()

    $('#toss-reaction').click ->
      $('#react-button').removeClass('display-none')
      $('.react-results-container').addClass('display-none')
      $('.reactions-and-react-button').removeClass('display-none')
      recordRTC.clearRecordedData()
      $('.react-results-container video').remove()

  _controlButtons: ->
    $('#mute-microphone-button').on 'click', @_toggleMic
    $('#mute-volume-button').on 'click', @_toggleVolume

  _newPostButton: ->
    $newForm = $("#new_post")
    $newForm.on "ajax:success", (e, data, status, xhr) ->
      newPost = new NewPost
      newPost.hideNewPost()
      postId = data.id
      binId = data.bin_id
      $("#guide-contents tr[data-guide-bin-id='#{binId}']").append("<td data-guide-post-id=\"#{postId}\"><button class=\"selected-show\"></button></td>")
      $('.selected-show').text(data.title)
      window.postFromGuide(binId: binId, postId: postId)

    $newForm.on "ajax:error", (e, xhr, status, error) ->
      newPost = new NewPost
      newPost.hideNewPost()

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
