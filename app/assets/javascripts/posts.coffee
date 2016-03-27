#= require ./channels/post-channel

class @Posts
  constructor: (options) ->
    $('.flash.notice').delay(3500).fadeOut 1400
    $('.new-post-button').on 'click', =>
      @showNewPost()

    $('.clear-button').on 'click', =>
      @hideNewPost()

    $(document).keyup (e) =>
      if e.keyCode == 78 # n
        if $('.new-post-button').is(':visible') && !$('input').is(':focus')
          @showNewPost()
      if e.keyCode == 27 # esc
        if $('.clear-button').is(':visible')
          @hideNewPost()

  showNewPost: ->
    $('.new-post-container').toggle true
    $('.new-post-button').toggle false
    $('.new-post-title input').focus()

  hideNewPost: ->
    $('.new-post-container').toggle false
    $('.new-post-button').toggle true
