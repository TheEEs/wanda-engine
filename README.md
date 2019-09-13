[![Build Status](https://travis-ci.org/TheEEs/wanda-engine.svg?branch=master)](https://travis-ci.org/TheEEs/wanda-engine)
[![GitHub release](https://img.shields.io/github/release/TheEEs/wanda-engine.svg)](https://github.com/TheEEs/wanda-engine/releases)
![GitHub](https://img.shields.io/github/license/TheEEs/wanda-engine)
# wanda-engine
Wanda is a web framework aimed to make web development workflow more enjoyable and easier by mimic the best parts of Ruby on Rails. By being written in ![Crystal Programing language](https://github.com/crystal-lang/crystal), this framework also attemp to solve the performance matter of Ruby language but still give developers the same felling as if they were making app in Ruby/Rails.

Wanda-engine is the core parts that difine and drive structure and workflow of an wanda-based application. The engine is required by default in ![Wanda Template](https://github.com/TheEEs/wanda). Thanks to many other developers, the framework consists of the following shards:

* **Kemal** : provide handy DSLs for communicating with HTTP server.
* **Jennifer.cr** : ActiveRecord insprited database ORM for Crystal.
* **wanda-csrf** : Based on ![kemal-csrf](https://github.com/kemalcr/kemal-csrf), adding csrf projection to your wanda application.
* **schedule.cr** : running tasks at specific time. 
* **inflector.cr** : Crystal's port of Rails's ActiveSupport
* **cache**: Support caching

The **Wanda Framework** focuses mainly on backend-development, that means how front-end stuff will be done is completely up to you. The default (and recommended) setup at ![Wanda Template](https://github.com/TheEEs/wanda) uses VueJS(*with single file components supported*), axios and turbolinks. Bundled using webpack4.

## Installation

1. In the ![Wanda Template](https://github.com/TheEEs/wanda), add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     wanda:
       github: TheEEs/wanda
       version: 0.1.1
   ```

2. Run `shards install`

After installation there will be two files *bin/sam.cr* and *bin/wanda.cr* lie in your project directory. *bin/sam.cr* is a task manager containing code for generating, destroying files, database migration, scaffolding application.

*bin/wanda.cr* is the entry-file of Wanda app. To run your application, type:
```shell
$ crystal bin/wanda.cr
```

## Development

TODO: 
* 1. Add support for other databases
* 2. Add support for websocket
* 3. Make view caching more flexible

## Contributing

1. Fork it (<https://github.com/your-github-user/wanda/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [TheEEs](https://github.com/ThEEs) - creator and maintainer
