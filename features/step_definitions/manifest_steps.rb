require 'tempfile'

Given /^the manifest$/ do |text|
  @manifest = text
end

When /^the manifest is applied$/ do
  manifest_file = Tempfile.new('manifest')

  begin
    manifest_file.write @manifest
    manifest_file.close

    system('bundle', 'exec', 'puppet', 'apply', '--debug', '--detailed-exitcodes', manifest_file.path)

    @changes = false
    @failures = false

    # See http://docs.puppetlabs.com/man/agent.html for a dexcription of puppet agent's exit codes
    # when using the --detailed-exitcodes option
    @changes = ($?.exitstatus & 2) > 0
    @failures = ($?.exitstatus & 4) > 0

    raise "puppet apply failed.  Exit code #{$?.exitstatus}" if $?.exitstatus < 0 or $?.exitstatus > 6
    raise "puppet apply generated failures.  Exit code #{$?.exitstatus}" if @failures
  ensure
    manifest_file.delete
  end
end

Then /^changes were applied$/ do
  @changes.should == true
end