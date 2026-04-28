module Radd
  class RaddError < StandardError; end
  class ConfigurationError < StandardError; end
  class Forbidden < RaddError; end
  class InvalidRequest < RaddError; end
  class UpdateError < RaddError; end
end
