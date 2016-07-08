class @RoomChannel
  constructor: (options) ->
    @mobile = options.mobile
    roomToken = options.roomToken

    boardKeyPress = (e) ->
      if e.which == 13 && $('#board').val() != '' && e.shiftKey == false
        window.commentChannel.perform("comment", comment: $('#board').val(), post_id: $('.post-header').data('post-id'))
        $('#board').blur()
        return false;

    window.commentChannel = App.cable.subscriptions.create "CommentChannel",
      connected: ->
        $('#board').keypress boardKeyPress

        window.addReaction = (postId, options={}) =>
          @perform("add_reaction", post_id: postId)

      disconnected: ->
        console.log('disconnected')

      rejected: ->
        console.log('rejected')

      received: (data) ->
        if data.action == 'add_reaction' && data.post_id == $('.post-header').data('post-id')
          videoURL = data.reaction_url
          $('.reactions-container').prepend("<div class=\"video-container\"><video class=\"reaction-video\" src=\"#{videoURL}\" autoplay controls=true></video></div>")
        else if data.action == 'new_comment' && data.post_id == $('.post-header').data('post-id')
          $('#board').val(data.comment)
          $('.edited-by').text(data.edited_by)

    App.cable.subscriptions.create { channel: "RoomChannel", room: roomToken, mobile: @mobile == 'mobile' },
      connected: ->
        window.nextPost = =>
          @perform("next_post", post_id: $('.post-header').data('post-id'), bin_id: $('.bin-header').data('bin-id'), from_token: window.fromToken)
          
        window.postFromGuide = (options) =>
          @perform("next_post", guide: true, post_id: options.postId, bin_id: options.binId, from_token: window.fromToken)

        nextPostClick = ->
          window.nextPost()

        prevPostClick = =>
          @perform("prev_post", post_id: $('.post-header').data('post-id'), bin_id: $('.bin-header').data('bin-id'))

        channelUpClick = =>
          @perform("channel_up", post_id: $('.post-header').data('post-id'), bin_id: $('.bin-header').data('bin-id'))

        channelDownClick = =>
          @perform("channel_down", post_id: $('.post-header').data('post-id'), bin_id: $('.bin-header').data('bin-id'))

        window.matchingSwtich = (status) =>
          if status == 'party'
            @perform("set_matching", matching: true, solo: false)
          else if status == 'friends'
            @perform("set_matching", matching: false, solo: false)
          else
            @perform("set_matching", matching: false, solo: true)
            
        window.endConversation = (data) =>
          @perform("end_conversation", data)
          
        window.addShow = (data) =>
          data.from_token = window.fromToken
          @perform("add_show", data)
        
        $('#channel-up').click channelUpClick
        $('#channel-down').click channelDownClick
        $('#prev-post').click prevPostClick
        $('#next-post').click nextPostClick

      disconnected: ->

      rejected: ->

      received: (data) ->
        if data.action == 'advance_post'
          return if window.status == 'ending' && data.from_token != window.fromToken
          return if $('.static:not(.hidden)').length
          
          if data.new_post
            guideBuildAndSelect(data)
            window.addShowSuccess()
          else
            guideSelect(postId: data.id, binId: data.bin_id)

          $('.embeded-content-container').remove()

          if @mobile != 'mobile'
            min = 1
            max = 11
            randNum = Math.floor(Math.random() * (max - min)) + min
            $('.video-panel').removeClass('hidden')
            $("#static#{randNum}").removeClass('hidden')
            staticVideo = document.getElementById("static#{randNum}")
            staticVideo.volume = 0.05;
            staticVideo.play()

            $(staticVideo).bind 'ended', ->
              $('.static').addClass('hidden')
              $('.video-panel').addClass('hidden')

          $('.post-header').text(data.title)
          $('.post-header').attr('title', data.title)
          $('.post-header').data('post-id', data.id)

          $('.bin-header').text(data.bin_title)
          $('.bin-header').data('bin-id', data.bin_id)
          
          $('.bin-channel-number').text("#{data.bin_number} #{data.bin_abbreviation}")
          $('.bin-logo').attr('src', data.bin_logo_src)

          description = data.bin_description || ''
          $('.bin-description').attr('title', description)

          if description.length > 140
            description = description.slice(0, 140)
          $('.bin-description').text(description)

          $('.posted-by').text(data.posted_by)

          clearTimeout(window.durationTimeout)
          if data.duration
            window.durationTimeout = setTimeout (->
              window.nextPost()
              return
            ), data.duration * 1000
          else if data.format_type != 'youtube' && data.format_type != 'vimeo' && data.format_type != 'twitch' && data.format_type != 'soundcloud'
            window.durationTimeout = setTimeout (->
              window.nextPost()
              return
            ), 45000

          $container = $('.content-panel')

          $('.preview').remove()
          if data.link && data.full_url && !data.format_link
            $container.append("<a target=\"_blank\" class=\"preview\" href=\"\"></a>")
            $('.preview').text(data.full_url)
            $('.preview').attr('href', data.full_url)

          $('.well.post-content').remove()
          if data.text_content
            $container.prepend("<div class=\"well post-content\"></div>")
            $('.content-panel .well').text(data.text_content)
            if data.text_content.length > 500
              $container.append("<div class=\"btn btn-info read-more\" aria-label=\"Left Align\"><span class=\"fa fa-file-text-o fa-lg\" aria-hidden=\"true\"></span> Read more</div>")
              options = {
                closeIcon: '<div class=\"escape-container\"><span class=\"glyphicon glyphicon-remove\" aria-hidden=\"true\"></span></div>',
                otherClose: '.escape-icon',
                afterOpen: ->
                  $('.featherlight-content').append('<div class=\"btn escape-icon\">esc</div>')
                  $('.featherlight-content .well').text(data.text_content)
              }
              $('.read-more').featherlight('<div class=\"well\"></div>', options);

          if data.format_link
            $container.prepend("<div class=\"embed-responsive embed-responsive-16by9 embeded-content-container\"><div class=\"embeded-content-wrapper #{data.format_type || ''}\"></div></div>")
            $wrapper = $('.embeded-content-wrapper')
            if data.format_type == 'imgur'
              $('.embeded-content-container').removeClass('embed-responsive-16by9')
              $('.embeded-content-container').removeClass('embed-responsive')
              $wrapper.append("<blockquote class=\"imgur-embed-pub\" lang=\"en\" data-id=#{data.format_link}><a href=\"//imgur.com/#{data.format_link}\"></a></blockquote>")
              $wrapper.append("<script async src=\"//s.imgur.com/min/embed.js\" charset=\"utf-8\"></script>")
            else if data.format_type == 'twitter'
              $('.embeded-content-container').removeClass('embed-responsive-16by9')
              $('.embeded-content-container').removeClass('embed-responsive')
              $wrapper.append("<blockquote class=\"twitter-tweet\" lang=\"en\"><a href=#{data.format_link}></a></blockquote>")
              $wrapper.append("<script async src=\"//platform.twitter.com/widgets.js\" charset=\"utf-8\"></script>")
            else if data.format_type == 'gfycat'
              $('.embeded-content-container').removeClass('embed-responsive-16by9')
              $('.embeded-content-container').removeClass('embed-responsive')
              $wrapper.append("<div class=\"gfycat-wrapper\"><iframe class=\"gfycat-iframe\" src='https://gfycat.com/ifr/#{data.format_link}' allowfullscreen></iframe></div>")
            else if data.format_type == 'giphy'
              $wrapper.append("<iframe src=\"//giphy.com/embed/#{data.format_link}?html5=true\" frameBorder=\"0\" class=\"giphy-embed\" allowFullScreen></iframe>")
            else if data.format_type == 'soundcloud'
              $wrapper.append("<iframe id=\"sc-widget\" src=\"https://w.soundcloud.com/player/?url=http://soundcloud.com/#{data.format_link}\"></iframe>")
              widgetIframe = document.getElementById('sc-widget')
              widget = SC.Widget(widgetIframe)
              widget.bind SC.Widget.Events.READY, ->
                widget.play()
                widget.setVolume 10
                return
              end = false
              widget.bind SC.Widget.Events.FINISH, ->
                widget.getCurrentSound (sound) ->
                  widget.getSounds (sounds) ->
                    if end
                      window.nextPost()
                    if sound.id == sounds[sounds.length - 1].id
                      end = true
                    return
                  return
                return
            else if data.format_type == 'vimeo'
              autoPlay = if @mobile == 'mobile' then '0' else '1'
              $wrapper.append("<iframe src=\"//player.vimeo.com/video#{data.format_link}?portrait=0&color=333&autoplay=#{autoPlay}\" width=\"640\" height=\"390\" frameborder=\"0\" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>")
            else if data.format_type == 'youtube'
              $wrapper.append("<div id=\"ytplayer\"></div>")
              onPlayerReady = (event) ->
                if @mobile != 'mobile'
                  event.target.playVideo()
                  event.target.setVolume 10

              onPlayerStateChange = (event) ->
                if event.target.getPlayerState() == 0
                  window.nextPost()

              onPlayerError = (event) ->
                window.nextPost()

              if YT
                player = new (YT.Player)('ytplayer',
                  height: '720'
                  width: '1280'
                  playerVars:
                    start: data.start_time
                  videoId: data.format_link
                  events: 'onReady': onPlayerReady, 'onStateChange': onPlayerStateChange, 'onError': onPlayerError)
              else
                window.onYouTubeIframeAPIReady = ->
                  player = new (YT.Player)('ytplayer',
                    height: '720'
                    width: '1280'
                    playerVars:
                      start: data.start_time
                    videoId: data.format_link
                    events: 'onReady': onPlayerReady, 'onStateChange': onPlayerStateChange, 'onError': onPlayerError)
            else if data.format_type == 'twitch'
              $wrapper.append("<div id=\"twitchplayer\"></div>")
              success = ->
                options =
                  width: 1280
                  height: 720
                  channel: data.format_link
                player = new (Twitch.Player)('twitchplayer', options)
                if @mobile != 'mobile'
                  player.setVolume 0.1
                  player.play()
                player.addEventListener 'ended', ->
                  window.nextPost()
                return

              $.ajax
                url: 'https://player.twitch.tv/js/embed/v1.js'
                dataType: 'script'
                success: success
          else
            $container.prepend("<div> </div>")

          $('#board').val(data.comment || '')
          $('.edited-by').text(data.edited_by || '')

          $('.reactions-container').empty()
          if data.reaction_urls.length
            for url in data.reaction_urls
              $('.reactions-container').append("<div class=\"video-container\"><video class=\"reaction-video\" src=\"#{url}\" controls=true></video></div>")
