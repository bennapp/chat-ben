class @Info
  constructor: (options) ->
    if window.hasStorage() && !localStorage.getItem("seen-info")
      $infoContainer = $('.info-container')

      configuration =
        variant: 'info'
        otherClose: '#info-go-button'
        beforeOpen: ->
          $infoContainer.removeClass('invisible')
        afterOpen: ->
          $('#info-lookup-input').focus ->
            $(this).select()
        afterClose: ->
          if window.hasStorage()
            localStorage.setItem('seen-info', true)

      $info = $.featherlight($infoContainer, configuration)
      $info.open()
    