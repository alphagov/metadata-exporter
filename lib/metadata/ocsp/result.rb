module Metadata
  module Ocsp
    Result = Struct.new(:status, :reason) do
      def initialize(status, reason = nil)
        @status = status
        if status == :revoked
          @reason = reason
        end
      end

      def revoked?
        @status == :revoked
      end
    end
  end
end
