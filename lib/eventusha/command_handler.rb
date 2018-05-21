module Eventusha
	class CommandHandler
	  attr_reader :command

	  def initialize(command)
	    @command = command
	  end

	  def self.execute(command)
	    handler = new(command)
	    handler.execute
	  end

		def self.aggregate(aggregate_name)
			define_method :aggregate do
		    "Aggregates::#{aggregate_name.to_s.classify}".constantize
		  end
		end
	end
end
