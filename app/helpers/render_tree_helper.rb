# DOC:
# We use Helper Methods for tree building,
# because it's faster than View Templates and Partials

# use h.html_escape(node.content) for safe content

module RenderTreeHelper
  class Render
    class << self
      attr_accessor :h, :options

      def render_node(h, options)
        @h, @options = h, options
        node = options[:node]
        class_based_on_state = ''
        usertask = options[:node].usertasks.first
        if usertask.completed?
          class_based_on_state = "alert-success"
        elsif usertask.in_progress?
          class_based_on_state = "alert-warning"
        elsif usertask.submitted?
          class_based_on_state = "alert-warning"
        else
          class_based_on_state = "alert-start"
        end

        "<li>
          <div class=#{ class_based_on_state } >
            <p>
              #{ show_link }
              #{ controls }
            </p>
          </div>
          #{ children }
        </li>
        "
      end

      def show_link
        node = options[:node]
        ns = options[:namespace]
        title_field = node.send(options[:title])
        usertask = options[:node].usertasks.first
        unless usertask.not_started? || usertask.restart?
          url = h.url_for(usertask)
          title_field = h.link_to(title_field, url, method: :get)
        end
        "<div><h4> #{ title_field } </h4></div>"
      end

      def controls
        link_text = "Start #{ options[:node].need_review? ? 'Exercise' : 'Task' } "
        usertask = options[:node].usertasks.first
        if usertask.not_started?
          url = h.url_for(controller: :usertasks, action: :start, id: usertask)
          link_text = h.link_to(link_text, url, method: :get)
        else
          link_text = Task::STATE[usertask.aasm_state.to_sym]
          if usertask.restart?
            url = h.url_for(controller: :usertasks, action: :restart, id: usertask)
            link_text = h.link_to(link_text, url, method: :get)
          end
        end
        "
          <div>
            <p>#{ link_text }</p>
          </div>
        "
      end

      def children
        unless options[:children].blank?
          "<ol class='tree col-xs-16'>#{ options[:children] }</ol>"
        end
      end
    end
  end
end
