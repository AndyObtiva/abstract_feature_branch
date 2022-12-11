# TODO

- Add gem `post_install_message` with post install instructions, including how to run Rails generator
- Test with real rails app without and with redis
- Consider removing `redis` as a dependency and making it a setup step instead, to keep the gem lighter.
- Support newer versions of Redis
- Support `connection_pool` gem to enable working with a Redis `ConnectionPool`
- Document that Ruby 3.1 and Rails 7 are supported by this library.
