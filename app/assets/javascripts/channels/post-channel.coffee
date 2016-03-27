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
          $badge = $('li#' + postId + ' .badge')

          if numWaiting == 0
            $badge.remove()
          else
            if $badge.length != 0
              $badge.tooltip().attr('data-original-title', numWaiting + waitingToChatMessage)
              $badge.text(numWaiting)
            else
              $('li#' + postId + ' .count-container').prepend("<span class=\"badge\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"#{numWaiting} waiting to chat right now!\">#{numWaiting}</span>")
              $('li#' + postId + ' .badge').tooltip().attr('data-original-title', numWaiting + waitingToChatMessage)

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
