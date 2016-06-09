class @NewPost
  constructor: (options) ->
    $('.new-post-button').on 'click', (event) =>
      return unless forceSignIn(event)
      @showNewPost()

    $('.clear-button').on 'click', =>
      @hideNewPost()

    $(document).keyup (e) =>
      if e.keyCode == 78 # n
        if $('.new-post-button').is(':visible') && !$('input').is(':focus') && !$('textarea').is(':focus')
          @showNewPost()
      if e.keyCode == 27 # esc
        if !$('textarea').is(':focus')
          if $('.clear-button').is(':visible')
            @hideNewPost()

  showNewPost: ->
    $('.new-post-container').toggle true
    $('.new-post-button').toggle false
    $('.btn.blink').hide()
    $('.content-container').hide()
    $('.new-post-title input').focus()

  hideNewPost: ->
    $('.new-post-container').toggle false
    $('.new-post-button').toggle true
    $('.content-container').show()
    $('.btn.blink').show()
