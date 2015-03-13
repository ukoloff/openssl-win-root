require 'ffi'
require 'openssl'
require 'fileutils'

require_relative "root/version"

module OpenSSL::Win::Root

  On = Gem.win_platform?

  module Crypt
    extend FFI::Library
    ffi_lib 'crypt32'
    ffi_convention :stdcall

    attach_function :open, :CertOpenSystemStoreA, [:pointer, :string], :pointer
    attach_function :close, :CertCloseStore, [:pointer, :uint], :int
    attach_function :enum, :CertEnumCertificatesInStore, [:pointer, :pointer], :pointer

    class Ctx < FFI::Struct
      layout :dwCertEncodingType, :uint,
        :pbCertEncoded, :pointer,
        :cbCertEncoded, :uint,
        :pCertInfo, :pointer,
        :hCertStore, :pointer

      def crt
        OpenSSL::X509::Certificate.new self[:pbCertEncoded].read_string self[:cbCertEncoded]
      end
    end

    # Based on Puppet::Util::Windows::RootCerts
    def self.each
      store = open nil, 'ROOT'
      begin
        ctx = nil
        yield Ctx.new(ctx).crt until (ctx = enum store, ctx).null?
      ensure
        close store, 0
      end
    end
  end if On

  def self.save(path=path)
    my={}
    Crypt.each do |crt|
      File.open File.join(path, name='%08x.0'%crt.subject.hash), 'w' do |f|
        my[name]=1
        f.puts <<-EOT
Subject: #{crt.subject}
Valid:   #{crt.not_before} - #{crt.not_after}
Saved:   #{self} v#{VERSION} @#{Time.now}
#{crt.to_pem}
        EOT
      end
    end
    Dir.glob File.join path, '*' do |f|
      File.unlink f unless my[File.basename f]
    end
  end

  def self.path
    return @path if @path
    x = File.expand_path '..', __FILE__
    x = File.dirname x until File.exists? File.join x, 'Gemfile'
    x = File.join x, 'pem'
    FileUtils.mkdir_p x
    @path = x
  end

  def self.inject
    OpenSSL::SSL::SSLContext::DEFAULT_CERT_STORE.add_path path
    path
  end

  def self.go!
    t = Thread.new{ save }
    at_exit{t.join}
    inject
  end

  go! if On

end
