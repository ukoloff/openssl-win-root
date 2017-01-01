# OpenSSL::Win::Root

[![Build status](https://ci.appveyor.com/api/projects/status/skiasd9u6i4udyhw?svg=true)](https://ci.appveyor.com/project/ukoloff/openssl-win-root)
[![Gem Version](https://badge.fury.io/rb/openssl-win-root.svg)](http://badge.fury.io/rb/openssl-win-root)

Fetch Root CA certificates from Windows system store.

## Abstract

Default installation of Ruby on Microsoft Windows provides no root certificates at all.
Secure connections are simply impossible.

Recommended fix is to load http://curl.haxx.se/ca/cacert.pem
and set SSL_CERT_FILE environment variable.

But Windows has its own certificate store.
This gem just access it,
fetch trusted root certificates
and feed them to Ruby's OpenSSL.

So, if you installed some certificates
or your company certificate is installed by Group Policy,
these certificates will be available to your Ruby program.
In addition, no network access is required.

Under other OSes this gem does nothing.

## Installation

Add this line to your application's Gemfile:

```ruby
  gem 'openssl-win-root' if Gem.win_platform?
```

And then execute:

```sh
  $ bundle
```

Or install it yourself as:

```sh
  $ gem install openssl-win-root
```

## Usage

Just `require 'openssl/win/root'`

If your project uses `Bundler.require`
(eg. Ruby on Rails) then just do nothing!

To test whether SSL works (or not):

```ruby
require 'net/http'
Net::HTTP.get(URI 'https://ya.ru').length
```

You can use fetched certificates in non-Ruby projects
by setting environment variable
`SSL_CERT_DIR` to result of `OpenSSL::Win::Root.path`
or via `-CApath` argument of `openssl` command.

## See also

  * [Win-Ca][] for [Node.js][]
  * [Rufus::Lua::Win][]
  * [Ruby on Windows][] Book

## Credits

  * [Ruby][]
  * [OpenSSL][]
  * [AppVeyor][]

[Rufus::Lua::Win]: https://github.com/ukoloff/rufus-lua-win
[Ruby on Windows]: http://rubyonwindowsguides.github.io/
[Ruby]: https://www.ruby-lang.org/
[OpenSSL]: https://www.openssl.org/
[AppVeyor]: http://www.appveyor.com/
[Win-CA]: https://github.com/ukoloff/win-ca
[Node.js]: https://nodejs.org/
