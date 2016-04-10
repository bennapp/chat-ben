class @RoomChannel
  constructor: (options) ->
    roomToken = options.roomToken

    App.cable.subscriptions.create { channel: "RoomChannel", room: roomToken },
      connected: ->
        console.log('You are in a room. What are you doing looking at the console log?!')
        window.nextPost = (postId, options={}) =>
          @perform("next_post", post_id: postId, first_post: options.firstPost)

        $('#next-post').click =>
          window.nextPost($('.post-header')[0].id)

      disconnected: ->
        console.log('disconnected')

      rejected: ->
        console.log('rejected')

      received: (data) ->
        action = data.action
        if action == 'next_post'
          # If somone refreshes the page they can next someone elses content
          # return if window.RoomShow.status == 'ending'
          $like = $('#like')
          if data.like
            $like.removeClass('btn-default')
            $like.addClass('btn-primary')
          else
            $like.addClass('btn-default')
            $like.removeClass('btn-primary')

          $('.like-count').text(data.like_count)
          $('.like-count').attr("data-post-id", data.id)

          $container = $('.content-container')
          $container.empty()
          $container.append("<h3 class=\"post-header\" id=\"#{data.id}\">#{data.title}</h3>")
          $container.append("<div class='posted-by-container'>submitted by <span class='posted-by'></span></div>")
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

          if !data.link && !data.text_content
            $container.append("<div class=\"well\">This post has no embeded link or description</div>")
