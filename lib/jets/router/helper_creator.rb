class Jets::Router
  class HelperCreator
    def initialize(options, helper_module=nil)
      @options = options

      @meth, @path, @to = @options[:method], @options[:path], @options[:to]
      @module, @prefix, @as = @options[:module], @options[:prefix], @options[:as]

      @controller, @action = @to.split('#')
      @upath, @ucontroller, @uprefix = underscore(@path), underscore(@controller), underscore(@prefix)
      @path_trunk = @path.split('/').first # posts/new -> posts

      @helper_module = helper_module || Jets::RoutesHelper
    end

    def def_meth(str)
      @helper_module.class_eval(str)
    end

    def underscore(str)
      return unless str
      str.gsub('-','_').gsub('/','_')
    end

    # Examples:
    #   posts_path: path: 'posts'
    #   admin_posts_path: prefix: 'admin', path: 'posts'
    def define_index_method
      as = @options[:as] || @path_trunk
      name = "#{as}_path"

      result = [@prefix, @path].compact.join('/')

      def_meth <<~EOL
        def #{name}
          "/#{result}"
        end
      EOL
    end

    # Example: new_post_path
    def define_new_method
      as = @options[:as]
      as ||= [@action, @path_trunk.singularize].compact.join('_')
      name = "#{as}_path"

      result = [@prefix, @path_trunk, @action].compact.join('/')

      def_meth <<~EOL
        def #{name}
          "/#{result}"
        end
      EOL
    end

    def define_show_method
      as = @options[:as] || @path_trunk.singularize
      name = "#{as}_path"

      result = [@prefix, @path_trunk].compact.join('/')

      def_meth <<~EOL
        def #{name}(id)
          "/#{result}/" + id.to_param
        end
      EOL
    end

    def define_edit_method
      as = @options[:as]
      as ||= [@action, @path_trunk.singularize].compact.join('_')
      name = "#{as}_path"

      result = [@prefix, @path_trunk].compact.join('/')

      def_meth <<~EOL
        def #{name}(id)
          "/#{result}/" + id.to_param + "/#{@action}"
        end
      EOL
    end

    #   index - {:to=>"posts#index", :path=>"posts", :method=>:get}
    #   new   - {:to=>"posts#new", :path=>"posts/new", :method=>:get}
    #   show  - {:to=>"posts#show", :path=>"posts/:id", :method=>:get}
    #   edit  - {:to=>"posts#edit", :path=>"posts/:id/edit", :method=>:get}
    #
    #   get "posts", to: "posts#index"
    #   get "posts/new", to: "posts#new" unless api_mode?
    #   get "posts/:id", to: "posts#show"
    #   get "posts/:id/edit", to: "posts#edit" unless api_mode?
    #
    # Interesting, the post, patch, put, and delete lead to the same url helper as the get method...
    #
    #   post "posts", to: "posts#create"
    #   delete "posts/:id", to: "posts#delete"
    #
    #   put "posts/:id", to: "posts#update"
    #   post "posts/:id", to: "posts#update" # for binary uploads
    #   patch "posts/:id", to: "posts#update"
    #
    def define_url_helpers!
      return unless @meth == :get

      case @action
      when 'index'
        define_index_method
      when 'new'
        define_new_method
      when 'edit'
        define_edit_method
      when 'show'
        define_show_method
      end
    end
  end
end
