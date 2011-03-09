# README

Zen is a modular CMS written on top of the awesome Ramaze framework.
Zen was built out of the frustration with Expression Engine, a popular CMS built on top of
the Codeigniter framework which in turn is written using PHP. While I really like Codeigniter,
ExpressionEngine and EllisLab there were several problems that bothered me.
So I set out to write a system that's loosely based on ExpressionEngine but fits my needs.
Because of this certain features may seem similar to those provided by EE and while at
certain points there are similarities there are also pretty big differences.

## Requirements

* Ramaze
* Sequel
* Liquid
* BCrypt
* JSON
* Ruby 1.9.2
* Defensio
* Thor
* RedCloth
* RDiscount
* Rake
* Sequel Sluggable

## Installation

Installing Zen using Rubygems is probably the easiest way:

    $ gem install zen
    $ zen app application_name

If you like to hack with the core of Zen it's best to install it using Git:

    $ git clone git://github.com/zen-cms/zen-core.git
    $ cd zen-core
    $ rake build:gem_clean

## License

Zen is licensed under the MIT license. For more information about this license open
the file "license.txt".