backupmasta
===========

Backupmasta — da masta of ur backups!

A simple webapp that connects remotely using ssh to a host, makes a database dump and saves it to Google Cloud Storage.

Build with Sinatra, Heroku and love.

[![Build Status](https://travis-ci.org/ZeroOneStudio/backupmasta.png?branch=master)](https://travis-ci.org/ZeroOneStudio/backupmasta)
[![Coverage Status](https://coveralls.io/repos/ZeroOneStudio/backupmasta/badge.png)](https://coveralls.io/r/ZeroOneStudio/backupmasta)
[![Dependency Status](https://gemnasium.com/ZeroOneStudio/backupmasta.png)](https://gemnasium.com/ZeroOneStudio/backupmasta)
[![Code Climate](https://codeclimate.com/github/ZeroOneStudio/backupmasta.png)](https://codeclimate.com/github/ZeroOneStudio/backupmasta)

How to start with your own backupmasta
======================================

You are to have a bunch of ENV variables to make Backupmasta work:

* `ENV['GOOGLE_STORAGE_ID']`
* `ENV['GOOGLE_STORAGE_SECRET']`
* `ENV['GITHUB_KEY']`
* `ENV['GITHUB_SECRET']`
* `ENV['SESSION_SECRET']`
* `ENV['SSH_PRIVATE_KEY']`

It should be set in an `env.rb` file at the root of the project. Example:

    ENV['GOOGLE_STORAGE_ID'] = "your_google_storage_id"

How to use backupmasta.herokuapp.com
====================================

Add this public key to `~/.ssh/authorized_keys` on a server where your MySQL is located:

    ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA1dLyuPXFKAW5Orce6+WpR0Gyrwg/eP1tU+NEBoeWGY+xvsvgtkb3Ou8Fh7Rs2PJuNqVurJxa0eI/V3fi6nxpkcDIQRXkGQjpMRqnl9eEG4WsmADJILcAMBhm5ifL8wcVkMGkTVOYAisJLJkLLl0RaqSSlqxpaAlcnyVET0NMAD/oGlXAw9HVeROoWHhdsgL+hsObPr3KQOeX9Qp6FHAylRHkw6K1lh8rBZ8FQa/7hE8mo3+hQnM8EtlRa5iRYdjKX53ybx8Vz8TQ82ySJ49Xr31Y0cl5vDD3RPgZY8nPWerFkjY8+ufTS/opMr09MzqCr6auJ1bMwo27J73H61o8sQ== u34164@26e45ebb-4c01-4a80-8b62-b7faa6f79a64

To be continued ...


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/ZeroOneStudio/backupmasta/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

