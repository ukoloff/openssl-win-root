# Based on https://www.omniref.com/ruby/gems/puppet/3.2.0.rc2/files/lib/puppet/util/windows/root_certs.rb
require 'ffi'
require 'openssl'

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
  end

  def self.run
    store = open(nil, 'ROOT')
    ctx = nil
    begin
      while true
        ctx = enum store, ctx
        break if ctx.null?
        z = Ctx.new ctx
        crt = OpenSSL::X509::Certificate.new z[:pbCertEncoded].read_string z[:cbCertEncoded]
        puts "Subject: #{crt.subject}"
        puts "Valid:   #{crt.not_before} - #{crt.not_after}"
        puts crt.to_pem
        puts
      end
    ensure
      close store, 0
    end
  end

  run

end
