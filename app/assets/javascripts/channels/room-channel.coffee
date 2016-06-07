class @RoomChannel
  constructor: (options) ->
    roomToken = options.roomToken

    boardKeyPress = (e) ->
      if e.which == 13 && $('#board').val() != '' && e.shiftKey == false
        window.commentChannel.perform("comment", comment: $('#board').val(), post_id: $('.post-header')[0].id)
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
        if data.action == 'add_reaction' && data.post_id.toString() == $('.post-header')[0].id
          videoURL = data.reaction_url
          $('.reactions-container').prepend("<div class=\"video-container\"><video class=\"reaction-video\" src=\"#{videoURL}\" autoplay controls=true></video></div>")
        else if data.action == 'new_comment' && data.post_id.toString() == $('.post-header')[0].id
          $('#board').val(data.comment)
          $('.edited-by').text(data.edited_by)

    App.cable.subscriptions.create { channel: "RoomChannel", room: roomToken },
      connected: ->
        window.nextPost = (postId, options={}) =>
          @perform("next_post", post_id: postId, first_post: options.firstPost, bin_id: $('.bin-header').data('bin-id'))

        nextPostClick = ->
          window.nextPost($('.post-header')[0].id)

        previousePostClick = ->
          #

        $('#next-post').click nextPostClick
        $('#previous-post').click previousePostClick

      disconnected: ->

      rejected: ->

      received: (data) ->
        action = data.action
        if action == 'next_post'
          postHistory.push data.id unless data.first_post
          fullHistory.push data.id unless data.first_post

          # If somone refreshes the page they can next someone elses content
          # return if window.RoomShow.status == 'ending'
          $like = $('#like')
          $dislike = $('#dislike')
          if data.like
            $like.removeClass('btn-default')
            $like.addClass('btn-primary')
          else
            $like.addClass('btn-default')
            $like.removeClass('btn-primary')

          if data.dislike
            $dislike.removeClass('btn-default')
            $dislike.addClass('btn-danger')
          else
            $dislike.addClass('btn-default')
            $dislike.removeClass('btn-danger')

          $('.like-count').text(data.like_count)
          $('.like-count').attr("data-post-id", data.id)

          $container = $('.content-container')
          $container.empty()
          $container.append("<h4 class=\"post-header\" id=\"#{data.id}\">#{data.title}</h4>")
          $('.posted-by').text(data.posted_by)

          if data.link && data.full_url && !data.format_link
            $container.append("<a target=\"_blank\" class=\"preview\" href=\"\"></a>")
            $('.preview').text(data.full_url)
            $('.preview').attr('href', data.full_url)

          if data.text_content
            $container.append("<div class=\"well\"></div>")
            $('.content-container .well').text(data.text_content)
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
            $container.append("<div class=\"embed-responsive embed-responsive-4by3 embeded-content-container\"><div class=\"embeded-content-wrapper #{data.format_type || ''}\"></div></div>")
            $wrapper = $('.embeded-content-wrapper')
            if data.format_type == 'imgur'
              $wrapper.append("<blockquote class=\"imgur-embed-pub\" lang=\"en\" data-id=#{data.format_link}><a href=\"//imgur.com/#{data.format_link}\"></a></blockquote>")
              $wrapper.append("<script async src=\"//s.imgur.com/min/embed.js\" charset=\"utf-8\"></script>")
            else if data.format_type == 'twitter'
              $('.embeded-content-container').removeClass('embed-responsive-4by3')
              $('.embeded-content-container').removeClass('embed-responsive')
              $wrapper.append("<blockquote class=\"twitter-tweet\" lang=\"en\"><a href=#{data.format_link}></a></blockquote>")
              $wrapper.append("<script async src=\"//platform.twitter.com/widgets.js\" charset=\"utf-8\"></script>")
            else if data.format_type == 'vimeo'
              $wrapper.append("<iframe src=\"//player.vimeo.com/video#{data.format_link}?portrait=0&color=333\" width=\"640\" height=\"390\" frameborder=\"0\" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>")
            else if data.format_type == 'youtube'
              $wrapper.append("<div id=\"ytplayer\"></div>")
              onPlayerReady = (event) ->
                event.target.playVideo()
                event.target.setVolume 10

              onPlayerStateChange = (event) ->
                if event.target.getPlayerState() == 0
                  window.nextPost($('.post-header')[0].id)

              if YT
                player = new (YT.Player)('ytplayer',
                  height: '720'
                  width: '1280'
                  videoId: data.format_link
                  events: 'onReady': onPlayerReady, 'onStateChange': onPlayerStateChange)
              else
                window.onYouTubeIframeAPIReady = ->
                  player = new (YT.Player)('ytplayer',
                    height: '720'
                    width: '1280'
                    videoId: data.format_link
                    events: 'onReady': onPlayerReady)
            else if data.format_type == 'twitch'
              $wrapper.append("<div id=\"twitchplayer\"></div>")
              success = ->
                options =
                  width: 1280
                  height: 720
                  channel: data.format_link
                player = new (Twitch.Player)('twitchplayer', options)
                player.setVolume 0.1
                player.play()
                player.addEventListener 'ended', ->
                  window.nextPost $('.post-header')[0].id
                return

              $.ajax
                url: 'https://player.twitch.tv/js/embed/v1.js'
                dataType: 'script'
                success: success

          $('#board').val(data.comment || '')
          $('.edited-by').text(data.edited_by || '')

          $('.reactions-container').empty()
          if data.reaction_urls.length
            for url in data.reaction_urls
              $('.reactions-container').append("<div class=\"video-container\"><video class=\"reaction-video\" src=\"#{url}\" controls=true></video></div>")

