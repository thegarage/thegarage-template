# add support for focused specs with focus: true option
config.treat_symbols_as_metadata_keys_with_true_values = true
config.filter_run focus: true
config.run_all_when_everything_filtered = true
EOS

# enable controller tests to render views
config.render_views

# disable foo.should == bar syntax
config.expect_with :rspec do |c|
  c.syntax = :expect
end
