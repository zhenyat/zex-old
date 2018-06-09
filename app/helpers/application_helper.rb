module ApplicationHelper
  def app_name
    Rails.application.class.parent_name
  end

  # Selects a status mark to be displayed
  def status_mark status
    if status == 'active'
      image_tag('checkmark.png', size: '12x15', title: 'Active')
    else
      image_tag('archive.png',   size: '12x15', title: 'Archive')
    end
  end
end
