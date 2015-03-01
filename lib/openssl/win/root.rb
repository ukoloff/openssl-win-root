require 'ffi'
require 'openssl'
require "fileutils"

require_relative "root/version"

module OpenSSL::Win::Root

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
  end

  def self.save
    Crypt.each do |crt|
      puts <<-EOT
Subject: #{crt.subject}
Valid:   #{crt.not_before} - #{crt.not_after}
#{crt.to_pem}

      EOT
    end
  end

  def self.path
    return @path if @path
    x = File.expand_path File.dirname __FILE__
    x = File.dirname x until File.exists? File.join x, 'Gemfile'
    x = File.join x, 'pem'
    FileUtils.mkdir_p x
    @path = File.join x, 'cacert.pem'
  end

end
