class SpecLanguage < Zen::Controller::FrontendController
  map '/spec-language'

  def frontend_dutch
    session[:user].update(:frontend_language => 'nl')

    respond(Zen::Language.current, 200)
  end

  def frontend_english
    session[:user].update(:frontend_language => 'en')

    respond(Zen::Language.current, 200)
  end
end

class SpecLanguageBackend < Zen::Controller::AdminController
  map '/admin/spec-language'

  def backend_dutch
    session[:user].update(:language => 'nl')

    respond(Zen::Language.current, 200)
  end

  def backend_english
    session[:user].update(:language => 'en')

    respond(Zen::Language.current, 200)
  end
end
