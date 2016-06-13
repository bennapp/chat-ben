module ApplicationHelper
  def mobile_css?
    @mobile ||= mobile? ? 'mobile' : ''
  end

  def mobile?
    browser.device.mobile?
  end
end
