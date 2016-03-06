class ActiveUsersController < WebsocketRails::BaseController
  def initialize_session
    # perform application setup here
    # controller_store[:message_count] = 0
  end

  def count
    message = {count: 5}
    send_message :event_name, message
  end
end