class @Guide
  constructor: (options) ->
    $('#guide-contents').scrollTo('.selected-show', axis: 'x', offset: -20)
    $('#guide-contents').scrollTo('.selected-show', axis: 'y')

    $('.guide-table').on 'scroll', ->
      $('.guide-table:not(this)').scrollTop $(this).scrollTop()

    window.guideSelect = (options) ->
      $('.selected-show').removeAttr('class')
      $("#guide-contents tr[data-guide-bin-id='#{options.binId}'] td[data-guide-post-id='#{options.postId}'] button").attr('class', 'selected-show')
      $('#guide-contents').scrollTo('.selected-show', axis: 'x', offset: -20)
      $('#guide-contents').scrollTo('.selected-show', axis: 'y')

    $('.guide-container td').on 'click', (event) ->
      cell = event.target.parentNode
      row = event.target.parentNode.parentNode
      postId = $(cell).data('guide-post-id')
      binId = $(row).data('guide-bin-id')

      window.postFromGuide(binId: binId, postId: postId)
