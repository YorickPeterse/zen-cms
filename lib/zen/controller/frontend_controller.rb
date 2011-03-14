#:nodoc:
module Zen
  #:nodoc:
  module Controllers
    ##
    # Controller that should be extended by other controllers that can be accessed from
    # the web without having to log in. Frontend controllers don't have a layout and
    # use the Liquid template engine for all views.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class FrontendController < Zen::Controllers::BaseController
      engine :liquid
      layout :none
    end
  end
end
