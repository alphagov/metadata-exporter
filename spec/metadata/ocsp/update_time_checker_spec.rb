require 'metadata/ocsp/update_time_checker'
require 'metadata/ocsp/checker_error'
module Metadata
  module Ocsp
    describe UpdateTimeChecker do
      let(:checker){ UpdateTimeChecker.new }
      it "will not error when this_update is in the past" do
        this_update = Time.now - 10
        checker.check_time!(this_update)
      end
      it "will error when update_time is in the future" do
        this_update = Time.now + 3600
        expect{checker.check_time!(this_update)}.to raise_error CheckerError, "update time is in the future"
      end
      it "will allow for some clock skew when update_time is only slightly in the future" do
        this_update = Time.now + 10
        checker.check_time!(this_update)
      end
    end
  end
end
