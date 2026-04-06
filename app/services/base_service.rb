# frozen_string_literal: true

class BaseService
  class ValidationError < StandardError
    attr_reader :errors

    def initialize(errors)
      @errors = errors
      super("Validation failed")
    end
  end

  private

  def validate(contract, params)
    result = contract.call(params)
    raise ValidationError.new(result.errors.to_h) if result.failure?

    result.to_h
  end
end
