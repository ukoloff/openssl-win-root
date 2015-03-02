# OpenSSL::Win::Root

[![Gem Version](https://badge.fury.io/rb/openssl-win-root.svg)](http://badge.fury.io/rb/openssl-win-root)

Fetch Root CA certificates from Windows system store.

## Abstract

Default installation of Ruby on Microsoft Windows provides no root certificates at all.
Secure connections are simply impossible.

Recommended fix is to load http://curl.haxx.se/ca/cacert.pem and set SSL_CERT_FILE environment variable.

But Windows has its own certificate store. This gem just access it, fetch trusted root certificates
and feed them to Ruby's OpenSSL.

So, if you installed some certificates or your company certificate is installed by Group Policy,
these certificates will be available to your Ruby program. In addition, no network access is required.

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

If your project uses `Bundler.require` (eg. Ruby on Rails) then just do nothing!

To test whether SSL works (or not):

```ruby
require 'net/http'
Net::HTTP.get(URI 'https://ya.ru').length
```

## Credits

  * [Ruby](https://www.ruby-lang.org/)
  * [OpenSSL](https://www.openssl.org/)
  * [FFI](https://github.com/ffi/ffi)
