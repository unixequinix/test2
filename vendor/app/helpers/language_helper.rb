module LanguageHelper
  private

  def resolve_locale
    available_locales = HTTP::Accept::Languages::Locales.new(I18n.available_locales.map(&:to_s))
    browser_locales = HTTP::Accept::Languages.parse(request.env["HTTP_ACCEPT_LANGUAGE"].to_s)

    update_locale(([session[:locale]] + (available_locales & browser_locales) + ["en"]).compact.first)
  end

  def update_locale(locale)
    I18n.locale = locale
    session[:locale] = locale
  end
end
