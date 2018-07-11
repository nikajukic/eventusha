module Eventusha
  class Command
    include ActiveModel::Model

    attr_accessor :aggregate_id

    def self.attributes(*attributes)
      attr_accessor *attributes
      define_method :readable_attributes do
        attributes
      end
    end

    def execute
      return false if invalid?

      command_handler = find_command_handler(self)
      command_handler.execute(self)
    end

    def find_command_handler(command)
      "CommandHandlers::#{self.class.name.demodulize}".constantize
    end

    def attributes
      readable_attributes.each_with_object({}) do |attribute, attrs_hash|
        attrs_hash[attribute] = instance_variable_get("@#{attribute}")
      end.with_indifferent_access
    end
  end
end
