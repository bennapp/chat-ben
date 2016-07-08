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
      @addToChannel()

  addNewPost: ->
    $addShow = $('#add-show')
    window.addShow(value: $addShow.val())

  addToChannel: ->
    window.addToChannel()
