backupmasta
===========

Backupmasta — da masta of ur backups!

[![Code Climate](https://codeclimate.com/github/ZeroOneStudio/backupmasta.png)](https://codeclimate.com/github/ZeroOneStudio/backupmasta)

How to start with your own backupmasta
======================================

You are to have a bunch of ENV variables to make Backupmasta work:

* ENV['GOOGLE_STORAGE_ID']
* ENV['GOOGLE_STORAGE_SECRET']
* ENV['GITHUB_KEY']
* ENV['GITHUB_SECRET']

It should be set in an `env.rb` file at the root of the project. Example:

```Ruby
  ENV['GOOGLE_STORAGE_ID'] = "your_google_storage_id"
```

How to use backupmasta.herokuapp.com
====================================

Add this public key to `~/.ssh/authorized_keys` on a server where your MySQL is located:

    ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAuMMbjErzTpKbWJlmWnn9RjRpij2b8zSox3IFEzfb6OYxO5qRqghzYmBuVtAkLkwe6/KTT0URm6kBXWYt+CAdUOCEqnvlNkkr4SSsUvm06deUHYL4SObjquyZVSuTWrdJqygUu6L1Qf1QcLW7BVi7jhJvgmaPww0p7TlZ8fZkg8LSoqf2XtRnYf825FQsHajgwLvLlAzq0u/bA2Tr809fJxi3nzKAjFddoC2xPKlSXIB8fWfc4Ysqr/XawYQs2u2LmsSnJQK1LNu7X9p220+0sJTigC6kdLCbEka0JxP+FUfuS1Ohf3S5UC0fMNEP/j+dwDb4sGD4HKmpbBlgaDMTtQ== u18911@8a39c876-231c-48d2-accf-0523d43f329a

To be continued ...
