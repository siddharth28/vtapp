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
          class_based_on_state = "alert-success"
        elsif Task::STATE[options[:user].current_task_state(options[:node].id)] == Task::STATE[:in_progress]
          class_based_on_state = "alert-warning"
        elsif Task::STATE[options[:user].current_task_state(options[:node].id)] == Task::STATE[:submitted]
          class_based_on_state = "alert-warning"
        else
          class_based_on_state = "alert-info"
        end

        "<li>
          <div class=#{ class_based_on_state } >
            <div class='m-top m-down-x'>
              #{ show_link }
            </div>
            #{ controls }
          </div>
          #{ children }
        </li>
        "
      end

      def show_link
        node = options[:node]
        ns = options[:namespace]
        title_field = node.send(options[:title])
        usertask = options[:user].usertasks.find_by(task_id: node.id)
        if options[:user].current_task_state?(node.id)
          url = h.url_for(controller: :usertasks, action: :task_description, id: usertask)
          title_field = h.link_to(title_field, url, method: :get)
        end
        "<div class='m-top m-down'> <h4>#{ title_field }</h4></div>"
      end

      def controls
        link_text = "Start #{ options[:node].specific ? 'Exercise' : 'Task' } "
        if options[:user].current_task_state?(options[:node].id)
          link_text = Task::STATE[options[:user].current_task_state(options[:node])]
        else
          url = h.url_for(controller: :usertasks, action: :start_task, usertask: { user_id: options[:user], task_id: options[:node] })
          link_text = h.link_to(link_text, url, method: :get)
        end
        "
          <div>
            #{ link_text }
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
