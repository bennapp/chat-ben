module ApplicationHelper
  def mobile_css
    mobile? ? 'mobile' : ''
  end

  def mobile_small_btn
    mobile? ? 'btn-xs' : ''
  end

  def mobile?
    browser.device.mobile?
  end
end
