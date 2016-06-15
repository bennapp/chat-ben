class @Login
  constructor: (options) ->
    $('.btn.signup').on 'click', =>
      @showSignup()
      @transferInputs()

    $('.signup-clear-button').on 'click', @hideSignup
    $('.alert .glyphicon-remove').on 'click', @hideNotice

    window.forceSignIn = (event) ->
      if window.currentUser.name
        return true
      else
        $('.login-notice').removeClass('hidden')
        $('.login-field').focus()
        $('body').scrollTo('.login-field')

        return false

    $('#board').on 'focus', forceSignIn

  showSignup: ->
    $('.login-and-signup-button').addClass('hidden')
    $('.signup-form-container').removeClass('hidden')

  transferInputs: ->
    $loginField = $('.login-field')
    $passwordField = $('.password-field')
    $usernameField = $('.username-field')
    $registerPasswordField = $('.register-password-field')

    if $usernameField.val() == ''
      $usernameField.val($loginField.val())

    if $registerPasswordField.val() == ''
      $registerPasswordField.val($passwordField.val())

    if $registerPasswordField.val().length && $usernameField.val().length
      $('.email-field').focus()

  hideSignup: ->
    $('.signup-form-container').addClass('hidden')
    $('.login-and-signup-button').removeClass('hidden')

  hideNotice: (event) ->
    $(event.target.parentElement).addClass('hidden')
