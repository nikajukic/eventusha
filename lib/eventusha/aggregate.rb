module Eventusha
  class Aggregate
    attr_reader :aggregate_id

    def self.on(*event_classes, &block)
      event_classes.each do |event_class|
        handler_name = "on_#{event_class.name.demodulize.underscore}"
        define_method(handler_name, block)
        private(handler_name)
      end
    end

    def self.find(aggregate_id)
      events = Event.where(aggregate_id: aggregate_id)
      build_from(events)
    end

    def apply(event, published: false)
      create_event(event) unless published

      send(apply_event_method_name(event), event)
    end

    def self.build_from(events)
      object = self.new
      return object if events.blank?

      events.each do |event|
        event = event.becomes(event.name.constantize)
        object.apply(event, published: true)
      end

      object
    end

    private

    def apply_event_method_name(event)
      "on_#{event.method_name}"
    end

    def create_event(event)
      event.save
      event.publish
    end
  end
end
