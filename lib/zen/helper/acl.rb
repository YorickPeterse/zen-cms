#:nodoc:
module Ramaze
  #:nodoc:
  module Helper
    ##
    # This helper provides an easy way of working with the ACL system that
    # ships with Zen. Using this helper you can restrict access to methods,
    # view elements and pretty much everything else based on the user's
    # permissions.
    #
    # In order to use the ACL helper you'll need to define a trait named
    # "extension_name" in your classes. Once this trait have been set you
    # can use the "user_authorized?" method to verify the permissions of the current user.
    # The first parameter is an array of required permissions,
    # the second a boolean that indicates if either all or just a single permission must 
    # be set.
    #
    # For more information about the ACL system you should read the documentation
    # in the ACL controller, Users::Controller::AccessRules().
    #
    # @author Yorick Peterse
    # @since  0.1
    # @see    Users::Controller::AccessRules()
    #
    module ACL

      ##
      # Builds a hash containing the permissions for all controllers. First all group
      # based rules will be retrieved. If the user is in a super group he'll gain full
      # access. However, if there's a user specific rule it will overwrite the rules set
      # for the group. This means that if a group allows something but a user rule doesn't
      # the user won't be able to gain access to the resource.
      #
      # @author Yorick Peterse
      # @since  0.1
      # @return [Hash]
      #
      def extension_permissions
        if session[:access_rules]
          return session[:access_rules]
        end

        user            = session[:user]
        user_groups     = user.user_groups
        @used_rules     = {}
        available_rules = [:create_access, :read_access, :update_access, :delete_access]

        # First all group rules should be built
        user_groups.each do |group|
          # If it's a super group we'll add all rules
          if group.super_group === true
            ::Zen::Package::Controllers.each do |controller|
              @used_rules[controller] = [:create, :read, :update, :delete]
            end
          end

          group.access_rules.each do |rule|
            process_permissions(rule, available_rules)
          end
        end

        # Process all user specific rules
        user.access_rules.each do |rule|
          process_permissions(rule, available_rules)
        end

        # Store the rules in the user's session so that they don't have to be re-processed
        # every time this method is called.
        session[:access_rules] = @used_rules

        return @used_rules
      end
      
      ##
      # Checks if the user has the specified permissions for the current extension that 
      # was called. Returns true if this is the case and false otherwise.
      #
      # @author Yorick Peterse
      # @param  [Array] required Array of permissions that are required.
      # @param  [Boolean] require_all Boolean that specifies that the user should have 
      # ALL specified permissios. Setting this to false causes this method to return true 
      # if any of the permissions are set for the current user.
      # @return [TrueClass]
      #
      def user_authorized?(required, require_all = true)
        # Get the ACL list
        rules = extension_permissions
        node  = action.node.to_s

        if !rules.key?(node)
          return false
        end

        required.each do |req|
          if require_all === false and rules[node].include?(req)
            return true
          elsif !rules[node].include?(req)
            return false
          end
        end

        return true
      end

      private

      ##
      # Extracts and stores all the permissions from a given rule. 
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [Users::Model::AccessRule] rule Database record containing the details of
      # a single rule.
      # @param  [Array] available_rules All the available rules that can be used.
      #
      def process_permissions(rule, available_rules)
        available_rules.each do |available_rule|
          # Add the rule to the list
          if rule.send(available_rule) === true
            method = :push
          # Remove the rule
          else
            method = :delete
          end

          available_rule = available_rule.to_s.gsub('_access', '').to_sym
          controllers    = []

          # Process all controllers
          if rule.controller === '*'
            ::Zen::Package[rule.package].controllers.each do |name, controller|
              controllers.push(controller)
            end
          # Process a single controller
          else
            controllers.push(rule.controller)
          end

          # Add the rules for all the controllers
          controllers.each do |c|
            @used_rules[c] ||= []

            if method === :push and @used_rules[c].include?(available_rule)
              next
            end

            # Add or remove the permission
            @used_rules[c].send(method, available_rule)
          end
        end
      end

    end
  end
end
