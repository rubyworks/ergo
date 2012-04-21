module Fire

  # State class encapsulates a *state* definition.
  #
  class State
    attr :name
    attr :condition

    def initialize(nane, &condition)
      @name      = name
      @condition = condition
    end

    def call
      @condition.call
    end
  end

end
