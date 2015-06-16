require 'metadata/ocsp/update_time_checker'
require 'metadata/ocsp/checker_error'
module Metadata
  module Ocsp
    describe UpdateTimeChecker do
      let(:checker){ UpdateTimeChecker.new }
      it "will not error when this_update is in the past and next_update is in the future" do
        this_update = Time.now - 3600
        next_update = Time.now + 3600
        checker.check_times!(this_update, next_update)
      end
      it "will error when update_time is in the future" do
        this_update = Time.now + 3600
        next_update = Time.now + 3600
        expect{checker.check_times!(this_update, next_update)}.to raise_error CheckerError, "update time is in the future"
      end
      it "will error when next_update time is in the past" do
        this_update = Time.now - 3600
        next_update = Time.now - 3600
        expect{checker.check_times!(this_update, next_update)}.to raise_error CheckerError, "next update time has passed"
      end
    end
  end
end
