class @Login
  constructor: (options) ->
    $('.btn.signup').on 'click', =>
      @showSignup()

    $('.signup-clear-button').on 'click', =>
      @hideSignup()

  showSignup: ->
    $('.login-and-signup-button').addClass('hidden')
    $('.signup-form-container').removeClass('hidden')

  hideSignup: ->
    $('.signup-form-container').addClass('hidden')
    $('.login-and-signup-button').removeClass('hidden')
