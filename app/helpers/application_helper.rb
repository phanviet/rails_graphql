module ApplicationHelper
  # Returns the full title on a per-page basis.
  def full_title(page_title = nil)
    base_title = "Ruby on Rails Tutorial"
    if !page_title.present?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end
end
