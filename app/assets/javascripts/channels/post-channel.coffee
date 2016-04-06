class @PostChannel
  constructor: (options) ->
    App.cable.subscriptions.create "PostChannel",
      connected: ->
        console.log('connected')

      disconnected: ->
        console.log('disconnected')

      rejected: ->
        console.log('rejected')

      received: (data) ->
        action = data.action
        if action == 'num_waiting'
          postId = data.post_id
          numWaiting = data.num_waiting

          waitingToChatMessage = ' waiting to chat right now!'
          $dot = $('li#' + postId + ' .waiting-dot')

          if numWaiting == 0
            $dot.remove()
          else
            if $dot.length != 0
              $dot.tooltip().attr('data-original-title', numWaiting + waitingToChatMessage)
              $dot.text(numWaiting)
            else
              $('li#' + postId + ' .count-container').prepend("<span class=\"waiting-dot\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"#{numWaiting} waiting to chat right now!\"></span>")
              $('li#' + postId + ' .waiting-dot').tooltip().attr('data-original-title', numWaiting + waitingToChatMessage)

        else if action == 'create'
          id = data.id
          title = data.title
          user = data.user
          listItem = """
            <li class="list-group-item" id="#{id}">
              <div class="badge-and-title">
                <div class="count-container"></div>
                <div class="post-title-container">
                  <a href="/posts/#{id}">#{title}</a>
                </div>
              </div>
              <div class="edit-delete"><span class="posted-by">#{user}, seconds ago!</span></div>
              </li>
          """
          $('ul.list-group').prepend(listItem)

        else if action == 'destroy'
          $("#"+ data.id).remove()
        else
          #
