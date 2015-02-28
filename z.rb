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

    def crt
      OpenSSL::X509::Certificate.new self[:pbCertEncoded].read_string self[:cbCertEncoded]
    end
  end

  # Based on Puppet::Util::Windows::RootCerts
  def self.each
    ctx = nil
    store = open nil, 'ROOT'
    begin
      until (ctx = enum store, ctx).null?
        yield Ctx.new(ctx).crt
      end
    ensure
      close store, 0
    end
  end

  def self.save
    each do |crt|
      puts "Subject: #{crt.subject}"
      puts "Valid:   #{crt.not_before} - #{crt.not_after}"
      puts crt.to_pem
      puts
    end
  end

  save

end
