class BinChannel < ApplicationCable::Channel
  def subscribed
    stream_from "bin_#{params[:bin_id]}"
  end

  def unsubscribed
  end
end