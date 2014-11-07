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
        if Task::STATE[options[:user].current_task_state(options[:node].id)] == Task::STATE[:completed]
          class_based_on_state = "bg-success"
        elsif Task::STATE[options[:user].current_task_state(options[:node].id)] == Task::STATE[:in_progress]
          class_based_on_state = "bg-warning"
        else
          class_based_on_state = "bg-danger"
        end

        "
          <li>
            <div class=#{ class_based_on_state }>
              #{ show_link }
              #{ controls }
            </div>
            #{ children }
          </li>
        "
      end

      def show_link
        node = options[:node]
        ns = options[:namespace]
        title_field = options[:title]
        "<h4>#{ node.send(title_field) }</h4>"
      end

      def controls
        link_text = options[:node].specific ? 'Exercise' : 'Task'
        usertask = options[:user].usertasks.find_by(task_id: options[:node].id)
        if options[:user].current_task_state?(options[:node].id)
          link_text = Task::STATE[options[:user].current_task_state(options[:node])]
          url = h.url_for(controller: :usertasks, action: :task_description, id: usertask)
          method = :get
        else
          link_text = "Start #{ link_text }"
          url = h.url_for(controller: :usertasks, action: :start_task, usertask: { user_id: options[:user], task_id: options[:node] })
          method = :get
        end

        "
          <div>
            #{ h.link_to((link_text), url, method: method ) }
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
