class @NewPost
  constructor: (options) ->
    $('#add-link').on 'click', (event) =>
      return unless forceSignIn(event)
      @addNewPost()

    window.addShowSuccess = (data) ->
      $('#add-show').val('').blur()

    window.addShowFail = (data) ->
      console.log('fail')
      
    $('#add-to-channel').on 'click', (event) =>
      return unless forceSignIn(event)
      return if $('#add-to-channel').hasClass('btn-primary')
      $('#add-to-channel').removeClass('btn-info')
      $('#add-to-channel').addClass('btn-primary')
      $('.animate-fade-up').addClass('fade-up')
      $('.add-to-channel-icon').removeClass('fa-star-o')
      $('.add-to-channel-icon').addClass('fa-star')
      @addToChannel()

  addNewPost: ->
    $addShow = $('#add-show')
    window.addShow(value: $addShow.val())

  addToChannel: ->
    window.addToChannel()
