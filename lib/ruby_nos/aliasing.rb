module Aliasing

  module ClassMethods
    def attr_alias(new_attr, original)
      alias_method(new_attr, original) if method_defined? original
      new_writer = "#{new_attr}="
      original_writer = "#{original}="
      alias_method(new_writer, original_writer) if method_defined? original_writer
    end
  end

  def self.included klass
    klass.extend ClassMethods
  end
end