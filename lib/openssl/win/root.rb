require 'ffi'
require 'openssl'
require 'fileutils'

require_relative "root/version"

module OpenSSL::Win::Root

  On = Gem.win_platform?

  # Based on Puppet::Util::Windows::RootCerts
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

  # Path where certificates will be
  def self.path
    return @path if @path
    x = File.expand_path '..', __FILE__
    x = File.dirname x until File.exists? File.join x, 'Gemfile'
    x = File.join x, 'pem'
    FileUtils.mkdir_p x
    @path = x
  end

  # Almost c_rehash
  def self.save(path=path)
    names={}
    hashes={}
    Crypt.each do |crt|
      peers=hashes[hash=crt.subject.hash]||={}
      id=OpenSSL::Digest::SHA1.new.digest crt.to_der
      next if peers[id]
      names[name='%08x.%i' % [hash, peers.length]]=1
      peers[id]=1
      File.open File.join(path, name), 'w' do |f|
        f.puts <<-EOT
Subject: #{crt.subject}
Valid:   #{crt.not_before} - #{crt.not_after}
Saved:   #{self} v#{VERSION} @#{Time.now}
#{crt.to_pem}
        EOT
      end
    end
    Dir.glob File.join path, '*' do |f|
      File.unlink f rescue nil unless names[File.basename f]
    end
  end

  # Instruct OpenSSL to use fetched certificates
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
