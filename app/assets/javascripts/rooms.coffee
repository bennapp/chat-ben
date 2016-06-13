#= require ./channels/room-channel

class @RoomShow
  constructor: (options) ->
    @nick = currentUser.name
    @room = options.room
    @postId = options.postId
    @signalServer = options.signalServer
    @_setStatusWithSwitch()

    @_bindDom()

  onReactMousedown: ->
    return unless forceSignIn(event)
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
      $('.reaction-panel').append('<div class="glow-container"><span class="red-glow"></span><h1> You Are Reacting!</h1></div>')
      recordRTC.startRecording()

      setTimeout(=>
        @isHold = !@mouseup
      , 2000)

      setTimeout(=>
        @isTimeOut = !@mouseup
        if @isTimeOut
          recordRTC.stopRecording @stopRecordingRTC
      , 10000)

      setTimeout(=>
        if !@isHold
          recordRTC.stopRecording @stopRecordingRTC
      , 3000)

    errorCallback = (error) =>
      @stopRecordingRTC()
      console.log 'navigator.getUserMedia error: ', error

    navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia
    navigator.getUserMedia({ audio: true, video: true }, successCallback, errorCallback)

  stopRecordingRTC: (videoURL) =>
    @reactStream.getTracks()[0].stop() if @reactStream
    @reactStream.getTracks()[1].stop() if @reactStream
    $('.reaction-panel .glow-container').remove()
    $('.react-results-container').removeClass('display-none')
    $('.react-results-container').prepend("<video style=\"width:90%;\" autoplay=\"true\" src=\"#{videoURL}\"></video>") if videoURL
    $('#reaction-preview').addClass('display-none')

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

    $('#react-button').show()
    @setupRecordRTCDom()

    @_controlButtons()
    @_newPostButton()
    @_matchingSwitch()

  _setStatus: (status) ->
    @status = status
    status = switch status
      when 'not-waiting'
        'Flip the switch to watch with someone else'
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

  _matchingSwitch: ->
    $('#myonoffswitch').change (event) =>
      if forceSignIn(event)
        window.matchingSwtich(event.target.checked)
        if @status == 'waiting' && !event.target.checked
          @_setStatus('not-waiting')
          @stopWebRTC()
        else if @status == 'not-waiting' && event.target.checked
          @_setStatus('waiting')
          @_startWebRTC()
      else
        $(event.target).prop('checked', !event.target.checked)

  _setStatusWithSwitch: ->
    if $('#myonoffswitch').is(':checked')
      @_setStatus('waiting')
      @_startWebRTC()
    else
      @_setStatus('not-waiting')
      $('#localVideo').hide()

  stopWebRTC: ->
    $('#localVideo').hide()
    @webrtc.leaveRoom()
    @webrtc.stopLocalVideo()

  _startWebRTC: ->
    $('#localVideo').show()

    if @webrtc
      @webrtc.startLocalVideo()
    else
      @webrtc = new SimpleWebRTC
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

        $('.control-buttons').removeClass('display-none')
        $('.no-user-container').addClass('display-none')
        $('#next-post').removeClass('display-none')

        @_setStatus('chatting')

      @webrtc.on 'videoRemoved', (video, peer) =>
        @removeVideo(video, peer)

      @webrtc.on 'volumeChange', (volume, treshold) =>
        @showVolume document.getElementById('localVolume'), volume

  setupRecordRTCDom: ->
    $('#react-button').mousedown =>
      @onReactMousedown()

    $('#react-button').mouseup =>
      return unless forceSignIn(event)
      if @reactStream
        @mouseup = true
        $('#react-button').addClass('display-none')
        if @isHold && !@isTimeOut
          recordRTC.stopRecording @stopRecordingRTC
      else
        @stopRecordingRTC()

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
    $ratingForm = $("#new_post")
    $ratingForm.on "ajax:success", (e, data, status, xhr) ->
      newPost = new NewPost
      newPost.hideNewPost()
      postId = data.id
      binId = data.bin_id
      $("#guide-contents tr[data-guide-bin-id='#{binId}']").append("<td data-guide-post-id=\"#{postId}\"><button class=\"selected-show\"></button></td>")
      $('.selected-show').text(data.title)
      window.postFromGuide(binId: binId, postId: postId)

    $ratingForm.on "ajax:error", (e, xhr, status, error) ->
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
