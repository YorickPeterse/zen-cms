#:nodoc:
module Zen
  #:nodoc:
  module Controller
    ##
    # Controller that should be extended by other controllers that can be
    # accessed from the web without having to log in. Frontend controllers don't
    # have a layout and use the Liquid template engine for all views.
    #
    # @since  0.1
    #
    class FrontendController < Zen::Controller::BaseController
      engine :etanni
      layout :none
      helper :theme
    end # FrontendController
  end # Controller
end # Zen
