class @ChatAgain
  constructor: (options) ->
    @url = options.url
    chatAgain = =>
      postId = $('.post-header').data('post-id')
      binId = $('.bin-header').data('bin-id')
      url = "#{@url}/bins/#{binId}"
      window.location = url

    $('#chat-again').on 'click', chatAgain
