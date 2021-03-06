class @Info
  constructor: (options) ->
    if window.hasStorage() && !localStorage.getItem("seen-info") && !options.mobile
      $infoContainer = $('.info-container')

      configuration =
        variant: 'info'
        closeIcon: ''
        otherClose: '#info-go-button'
        beforeOpen: ->
          $infoContainer.removeClass('invisible')
        afterOpen: ->
          $('#info-lookup-input').focus ->
            $(this).select()
        afterClose: ->
          if window.hasStorage()
            localStorage.setItem('seen-info', true)
            
          if window.playVid
            window.playVid()

      $info = $.featherlight($infoContainer, configuration)
      $info.open()
    