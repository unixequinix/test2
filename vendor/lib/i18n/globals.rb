require "i18n/globals/version"

module I18n
  class Config
    def globals
      @globals ||= {}
    end

    attr_writer :globals
  end

  class << self
    def translate(*args)
      if args.last.is_a?(Hash)
        args[-1] = config.globals.merge(args.last)
      else
        args << config.globals
      end
      super(*args)
    end
    alias_method :t, :translate
  end
end
