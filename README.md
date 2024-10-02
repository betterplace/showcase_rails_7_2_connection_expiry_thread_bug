# Rails 7.2.1 vanilla to showcase AR connection pool expiry bug
# 
### Steps to reproduce

(See https://github.com/rails/rails/issues/53147)

Run
```bash
# Clone and setup in /tmp
cd /tmp/
git clone https://github.com/betterplace/showcase_rails_7_2_connection_expiry_thread_bug
cd showcase_rails_7_2_connection_expiry_thread_bug/
bundle

# See it fail
bundle exec rspec spec/features/a_feature/rows_spec.rb:19

# See it pass without the migration_error setting
git checkout 82479acb2c107d2d01cfa076421d07f877c1828c
bundle exec rspec spec/features/a_feature/rows_spec.rb:19

# See diff
git diff master config/
```

before commit https://github.com/betterplace/showcase_rails_7_2_connection_expiry_thread_bug/commit/6254e665c58f447b3030f2a899a7030e9d640670 its passes.
After it fails with `ActiveRecord::ActiveRecordError` (Cannot expire connection, it is owned by a different thread).

The commit sets the value of `config.active_record.migration_error` to `:page_load` in `config/environments/test.rb`.

Note that the actual controller, resource, route and migration state seems not to influence the error.

Running the other spec, which is not marked as `js: true` via `bundle exec rspec spec/features/a_feature/rows_spec.rb:10` or running the whole suite *does not fail*.

### Background

In the process of updating from Rails 7.1 to 7.2.1, our CI failed with "Cannot expire connection, it is owned by a different thread" errors, which were reproducible locally.

The error seems to only get thrown when you execute a single spec/specs in specific order and the setting 
```ruby
config.active_record.migration_error = :page_load
```

is set.

A prior similar error was found in https://github.com/rails/rails/issues/52973 and fixed in https://github.com/rails/rails/pull/53118 , but it didnt resolve this occurence.

### Expected behavior

Spec succeeds, or fails with actual expectation mismatch.

### Actual behavior

An error is thrown during spec execution:
```
    ActiveRecord::ActiveRecordError:
       Cannot expire connection, it is owned by a different thread: #<Thread:0x0000000106e57b38@puma srv tp 001 /Users/felixwolfsteller/.asdf/installs/ruby/3.2.0/lib/ruby/gems/3.2.0/gems/puma-6.4.3/lib/puma/thread_pool.rb:113 sleep_forever>. Current thread: #<Thread:0x000000010084b100 run>.
```

### System configuration
**Rails version**: 7.2.1

**Ruby version**: 3.2.5


