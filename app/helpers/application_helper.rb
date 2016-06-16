module ApplicationHelper
  def mobile_css
    mobile? ? 'mobile' : ''
  end

  def mobile_small_btn
    mobile? ? 'btn-xs' : ''
  end

  def mobile_vimeo_autoplay
    mobile? ? '0' : '1'
  end

  def mobile?
    browser.device.mobile?
  end
end
