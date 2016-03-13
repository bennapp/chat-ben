class AppearanceChannel < ApplicationCable::Channel
  def subscribed
    puts 'subscribed'
  end

  def unsubscribed
    puts 'unsubscribed'
  end

  def appear(data)
    puts 'appear'
    puts data
    current_user.appear on: data['appearing_on']
  end
end