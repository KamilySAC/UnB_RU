# frozen_string_literal: true

# Compatibility shim for Saikuro 1.2.1 on Ruby 3.4+.
# Saikuro does `require "rdoc/usage"` at load time but never actually calls it.
module RDoc
  def self.usage(*_args, &_block)
    nil
  end

  def self.usage_no_exit(*_args, &_block)
    nil
  end
end
