module ApplicationHelper
  def mobile?
    @mobile ||= mobile_device? ? 'mobile' : ''
  end

  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      request.user_agent =~ /Mobile|webOS/
    end
  end
end
