# DOC:
# We use Helper Methods for tree building,
# because it's faster than View Templates and Partials

# SECURITY note
# Prepare your data on server side for rendering
# or use h.html_escape(node.content)
# for escape potentially dangerous content
module RenderTreeHelper
  class Render
    class << self
      attr_accessor :h, :options

      def render_node(h, options)
        @h, @options = h, options

        node = options[:node]
        "
          <li>
            <div class='item'>
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
        url  = h.url_for(ns + [node])
        title_field = options[:title]

        "<h4>#{ h.link_to(node.send(title_field), url) }</h4>"
      end

      def controls
        link_text = options[:node].specific ? 'Exercise' : 'Task'
        usertask = options[:user].usertasks.find_by(task_id: options[:node].id)
        if options[:user].current_task_state?(options[:node].id)
          link_text = options[:user].current_task_state(options[:node])
          url = h.url_for(controller: :usertasks, action: :show, id: usertask, task_id: options[:node])
          method = :get
        else
          link_text = "Start #{ link_text }"
          url = h.url_for(controller: :usertasks, action: :create, usertask: { user_id: options[:user], task_id: options[:node] })
          method = :post
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
