class @RoomChannel
  constructor: (options) ->
    roomToken = options.roomToken

    App.cable.subscriptions.create { channel: "RoomChannel", room: roomToken },
      connected: ->
        console.log('connected')
        $('#next-post').click =>
          @perform("next_post", post_id: $('.post-header')[0].id)

      disconnected: ->
        console.log('disconnected')

      rejected: ->
        console.log('rejected')

      received: (data) ->
        console.log(data)
        action = data.action
        if action == 'next_post'
          $container = $('.content-container')
          $container.empty()
          $container.append("<h3 class=\"post-header\" id=\"#{data.id}\">#{data.title}</h3>")

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
            $container.append("<div class=\"embeded-content-container\"><div class=\"embeded-content-wrapper #{data.format_type || ''}\"></div></div>")
            $wrapper = $('.embeded-content-wrapper')
            if data.format_type == 'imgur'
              $wrapper.append("<blockquote class=\"imgur-embed-pub\" lang=\"en\" data-id=#{data.format_link}><a href=\"//imgur.com/#{data.format_link}\"></a></blockquote>")
              $wrapper.append("<script async src=\"//s.imgur.com/min/embed.js\" charset=\"utf-8\"></script>")
            else if data.format_type == 'twitter'
              $wrapper.append("<blockquote class=\"twitter-tweet\" lang=\"en\"><a href=#{data.format_link}></a></blockquote>")
              $wrapper.append("<script async src=\"//platform.twitter.com/widgets.js\" charset=\"utf-8\"></script>")
            else if data.format_type == 'vimeo'
              $wrapper.append("<iframe src=\"//player.vimeo.com/video#{data.format_link}?portrait=0&color=333\" width=\"640\" height=\"390\" frameborder=\"0\" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>")
            else if data.format_type == 'youtube'
              $wrapper.append("<iframe id=\"ytplayer\" type=\"text/html\" width=\"640\" height=\"390\" src=\"//www.youtube.com/embed/#{data.format_link}?autoplay=1&origin=https://www.chatben.co\" frameborder=\"0\"/>")

          if !data.format_link && !data.text_content
            $container.append("<div class=\"well\">This post has no link or description</div>")
