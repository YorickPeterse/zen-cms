module Comments
  #:nodoc
  class Plugin
    ##
    # The Comments plugin can be used to display a list of comments for a given
    # section entry.
    #
    # This plugin can be called as following:
    #
    #     plugin(:comments)
    #
    # Retrieving comments can be done by specifying a section entry's ID or
    # slug:
    #
    #     # Retrieve by ID
    #     plugin(:comments, :entry => 5)
    #
    #     # Retrieve by slug
    #     plugin(:comments, :entry => 'hello-world')
    #
    # For a full list of all available options see {#initialize}.
    #
    # For more information about all available options see
    # Comments::Plugin::Comments#initialize
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    class Comments
      include ::Zen::Plugin::Helper
      include ::Sections::Model
      include ::Comments::Model

      ##
      # Creates a new instance of the plugin and saves the specified
      # configuration options.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [Hash] options Hash with a set of options that determine how
      #  the comments should be retrieved.
      # @option options [String|Fixnum] :entry The slug or ID of the entry for
      #  which to retrieve all comments.
      # @option options [Fixnum] :limit The maximum amount of comments to
      #  retrieve.
      # @option options [Fixnum] :offset The row offset, useful for pagination
      #  systems.
      # @option options [TrueClass|FalseClass] :markup When set to true
      #  (default) the markup used in each comment will be converted to the
      #  appropriate format.
      #
      def initialize(options = {})
        @options = {
          :limit  => 20,
          :offset => 0,
          :markup => true,
          :entry  => nil
        }.merge(options)

        # Validate the :entry option
        validate_type(@options[:limit] , :limit , [Fixnum])
        validate_type(@options[:offset], :offset, [Fixnum])
        validate_type(@options[:entry] , :entry , [String, Fixnum])
        validate_type(@options[:markup], :markup, [FalseClass, TrueClass])
      end

      ##
      # Retrieves all comments based on the options set in the construct. The
      # comments are returned as an array.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      #
      def call
        # Get the section entry
        if @options[:entry].class == String
          entry = SectionEntry[:slug => @options[:entry]]
        else
          entry = SectionEntry[@options[:entry]]
        end

        # Now that we have the entry and the section we can start retrieving
        # all the comments.
        open     = CommentStatus[:name => 'open'].id
        comments = Comment \
          .filter(:section_entry_id => entry.id, :comment_status_id => open) \
          .limit(@options[:limit], @options[:offset]) \
          .all

        # Don't bother with all code below this if/end if we don't want to
        # convert the markup of each comment.
        return comments if @options[:markup] === false

        # Get the section for the comments. This is required to determine what
        # markup is used for the comments.
        section = entry.section

        # Convert the markup of each comment and convert each comment to a hash
        comments.each_with_index do |comment, index|
          user              = comment.user
          comment           = comment.values
          comment[:comment] = plugin(
            :markup, section.comment_format, comment[:comment]
          )

          # Conver the userdata to a hash as well
          comment[:user] = {}

          if !user.nil?
            user.values.each { |k, v| comment[:user][k] = v }
          end

          comments[index] = comment
        end

        return comments
      end
    end # Comments
  end # Plugin
end # Comments
