class @Guide
  constructor: (options) ->
    $('#guide-contents').scrollTo('.selected-show', offset: -200)

    window.guideSelect = (options) ->
      $('.selected-show').removeAttr('class')
      $("#guide-contents tr[data-guide-bin-id='#{options.binId}'] td[data-guide-post-id='#{options.postId}'] button").attr('class', 'selected-show')
      $('#guide-contents').scrollTo('.selected-show', offset: -200)
