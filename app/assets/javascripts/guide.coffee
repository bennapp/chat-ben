class @Guide
  constructor: (options) ->
    $('.selected-show').scrollintoview()

    $('#guide-contents').on 'scroll', (event) =>
      $('#channel-contents').scrollTop $(event.target).scrollTop()

    window.guideSelect = (options) ->
      $('.selected-show').removeAttr('class')
      $("#guide-contents tr[data-guide-bin-id='#{options.binId}'] td[data-guide-post-id='#{options.postId}'] button").attr('class', 'selected-show')
      $('.selected-show').scrollintoview()

    $('.guide-container td').on 'click', (event) ->
      cell = event.target.parentNode
      row = event.target.parentNode.parentNode
      postId = $(cell).data('guide-post-id')
      binId = $(row).data('guide-bin-id')

      window.postFromGuide(binId: binId, postId: postId)

    resizeGuide = ->
      headerHeight = $('.page-header').height()
      pageHeight = $('.room-page').height()
      windowHeight = $(window).height()

      $('.guide-table').css('max-height', parseInt(windowHeight - pageHeight - headerHeight))

    resizeGuide()

    resizeInfo = ->
      chatPanelWidth = $('.chat-panel-container').width()
      windowWidth = $(window).width()

      $('.guide-info').css('width', parseInt(windowWidth - chatPanelWidth))

    resizeInfo()
    
    window.resize = ->
      resizeGuide()
      resizeInfo()

    $(window).resize resize