# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'middleman' do
  watch(%r{^config.rb})
  watch(%r{^data/.*})
  watch(%r{^source/.*})

  watch(%r{^views/.*})
  watch(%r{^public/.*})
end

guard :rspec do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

