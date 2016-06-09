class @Login
  constructor: (options) ->
    $('.btn.signup').on 'click', =>
      @showSignup()

    $('.signup-clear-button').on 'click', =>
      @hideSignup()

    window.forceSignIn = (event) ->
      if window.currentUser.name
        return true
      else
        $('.login-notice').removeClass('hidden')
        $('.login-field').focus()

        return false

    $('#board').on 'focus', forceSignIn

  showSignup: ->
    $('.login-and-signup-button').addClass('hidden')
    $('.signup-form-container').removeClass('hidden')

  hideSignup: ->
    $('.signup-form-container').addClass('hidden')
    $('.login-and-signup-button').removeClass('hidden')
