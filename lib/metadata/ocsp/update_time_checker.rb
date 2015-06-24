module Metadata
  module Ocsp
    class UpdateTimeChecker
      def check_time!(this_update)
        nowish = Time.now + 120 # Add 2 minutes to account for clock skew

        if this_update > nowish then
          fail CheckerError, 'update time is in the future'
        end
      end
    end
  end
end
