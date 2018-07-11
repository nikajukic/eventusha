# Eventusha

Eventusha is an Event Sourcing framework for Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'eventusha'
```

Execute:

    $ bundle install

And then:

  $ rails generate eventusha:install
  $ rake db:migrate


## Usage

Event Sourcing and CQRS consist of a few different elements. Recommended folder structure inside app folder:
```
app
──cqrs
  ──aggregates
  ──command_handlers
  ──commands
  ──event_handlers
  ──events
```

### Controller

Inside controllers you need to execute commands.

```ruby
class BankAccountsController < ApplicationController
  def new
    @command = Commands::CreateBankAccount.new
  end

  def create
    @command = Commands::CreateBankAccount.new(bank_account_params)

    if @command.execute
      redirect_to [:bank_accounts]
    else
      render :new
    end
  end

  private

  def bank_account_params
    params.require(:bank_account)
          .permit(:first_name, :last_name)
  end
end

```

### Commands

Commands are instructions that are usually initiated by users, e.g. `CreateBankAccount`. Commands are defined inside `app/cqrs/commands` folder. User actions are validated inside commands using the `ActiveModel::Model`.

#### attributes
Use `attributes` method to define command attributes. These attributes are going to be saved as serialized event data.

```ruby
module Commands
  class CreateBankAccount < Eventusha::Command
    attributes :first_name, :last_name

    validates :first_name, presence: true
    validates :last_name, presence: true
  end
end
```

### Command Handlers

Command handlers are used for handling commands. They load defined aggregate and execute corresponding action on it. For each command you must define a command handler with the same name inside `app/cqrs/command_handlers` folder

#### aggregate
Use `aggregate` method to define which aggregate is going to be used. Selected aggregate must be defined in `app/cqrs/aggregates` folder. These attributes are going to be saved as serialized event data.

`aggregate :bank_account` will use `Aggregates::BankAccount` aggregate.

```ruby
module CommandHandlers
  class CreateBankAccount < Eventusha::CommandHandler
    aggregate :bank_account

    def execute
      bank_account = aggregate.new

      bank_account.create_bank_account(command.attributes)
    end
  end
end
```

You can create a new aggregate with `aggregate.new` or build by replaying all events with that aggregate_id using `aggregate.find(command.aggregate_id)`

```ruby
module CommandHandlers
  class PerformDeposit < Eventusha::CommandHandler
    aggregate :bank_account

    def execute
      bank_account = aggregate.find(command.aggregate_id)

      bank_account.perform_deposit(command.attributes)
    end
  end
end
```

### Aggregates
Aggregate is a main domain model. It is build by replaying events and it represents current state of a domain object.

When an action initiated from command handler is executed on an aggregate, one or more events are created and applied on current aggregate.

Define what happens on an aggregate when you replay an event.

```ruby
  on EventClass do |event|
    #define what happens on aggregate when you replay this event
  end
```

```ruby
module Aggregates
  class BankAccount < Eventusha::Aggregate
    def initialize
      @aggregate_id = SecureRandom.uuid
      @amount = 0
    end

    def create_bank_account(attributes)
      apply Events::BankAccountCreated.prepare(aggregate_id, attributes)
    end

    def perform_deposit(attributes)
      apply Events::DepositPerformed.prepare(aggregate_id, attributes)
    end

    private

    on Events::BankAccountCreated do |event|
      @aggregate_id = event.aggregate_id
      @amount = 0
      @first_name = event.first_name
      @last_name = event.last_name
    end

    on Events::DepositPerformed do |event|
      @amount += event.amount.to_i
    end
  end
end
```

### Events
Events describe what happened as a consequence of executing a command. Attributes defined on a command that was executed are saved as a `data` json object.

#### event_handler

Using event handler define which event handler is going to be used when this event is created. Selected event handler must be defined in `app/cqrs/event_handlers` folder.

`event_handler :bank_account` will use `EventHandlers::BankAccount` event handler.

#### store_accessor

You need to define accessors for data attributes saved in JSON.

```ruby
module Events
  class BankAccountCreated < Eventusha::Event
    event_handler :bank_account

    store_accessor :data, :first_name, :last_name
  end
end
```

### Event Handlers

Event handlers are usually updating view models after event is created. You need to define which event handler is going to be used for each event.

```ruby
module EventHandlers
  class BankAccount < Eventusha::EventHandler
    on Events::BankAccountCreated do |event|
      ::BankAccount.create(
        aggregate_id: event.aggregate_id,
        first_name: event.first_name,
        last_name: event.last_name,
        amount: 0
      )
    end

    on Events::DepositPerformed do |event|
      bank_account = ::BankAccount.find_by(aggregate_id: event.aggregate_id)
      bank_account.amount += event.amount.to_i
      bank_account.save
    end
  end
end
```

## Usage



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/eventusha. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
