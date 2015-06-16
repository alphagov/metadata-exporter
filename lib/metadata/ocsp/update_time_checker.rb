module Metadata
  module Ocsp
    class UpdateTimeChecker
      def check_times!(this_update, next_update)
        now = Time.now

        if this_update > now then
          fail CheckerError, 'update time is in the future'
        end

        if now > next_update then
          fail CheckerError, 'next update time has passed'
        end
      end
    end
  end
end
