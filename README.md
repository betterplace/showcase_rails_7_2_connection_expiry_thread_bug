# Rails 7.2.1 vanilla to showcase AR connection pool expiry bug
# 
### Steps to reproduce

(See https://github.com/rails/rails/issues/53147)

Run
```bash
bundle exec rspec spec/features/a_feature/rows_spec.rb:19
```

before commit <..> its green, after <..> it fails with `ActiveRecord::ActiveRecordError` (Cannot expire connection, it is owned by a different thread).

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


