module Leml
  class NoLemlKeyError < StandardError
    def initialize
      super("Leml key is not found. config. Please create `config/leml.key` and set the secret.\nFor further information, see: https://github.com/onunu/leml")
    end
  end

  class NoEditorError < StandardError
    def initialize
      super("No editor, please set environment variable.\nex) EDITOR=vim bundle exec rake leml:edit")
    end
  end

  class InvalidLemlKey < StandardError
    def initialize
      super("Key is invalid for decrypt, please check the value of `config/leml.key`")
    end
  end
end
