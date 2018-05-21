module Eventusha
	class EventHandler
	  def self.on(*event_classes, &block)
	    event_classes.each do |event_class|
	      handler_name = "on_#{event_class.name.demodulize.underscore}"
	      define_method(handler_name, block)
	      private(handler_name)
	    end
	  end
	end
end
