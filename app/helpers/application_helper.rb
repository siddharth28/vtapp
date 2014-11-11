module ApplicationHelper
  def errors_for_field(object, field)
    if object.errors[field].any?
      content_tag :span, class: "error_field text-danger" do
        "#{object.errors[field].join(', ')}"
      end.html_safe
    end
  end

  # FIXED
  # FIXME : Why returning string in this ?
  def state(path)
    'active' if current_page?(path)
  end
end