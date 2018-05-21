class Event < ApplicationRecord
  def self.prepare(aggregate_id, attributes)
    new(
      aggregate_id: aggregate_id,
      data: attributes,
      name: self.name
    )
  end

	def self.event_handler(handler_name)
		define_method :event_handler_class do
	    "EventHandlers::#{handler_name.to_s.classify}".constantize
	  end
	end

  def method_name
    name.demodulize.underscore
  end

  def publish
    event_handler_class.new.send("on_#{method_name}", self)
  end
end