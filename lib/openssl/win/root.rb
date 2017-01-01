require 'openssl'
require 'fileutils'
require 'fiddle/import'

require_relative "root/version"

module OpenSSL::Win::Root

  On = Gem.win_platform?

  # Based on Puppet::Util::Windows::RootCerts
  module Crypt
    extend Fiddle::Importer
    dlload 'crypt32'

    extern 'uintptr_t CertOpenSystemStoreA(uintptr_t, char*)', :stdcall
    extern 'int CertCloseStore(uintptr_t, unsigned long)', :stdcall
    extern 'void* CertEnumCertificatesInStore(uintptr_t, void*)', :stdcall

    Ctx = struct [
      'unsigned long dwCertEncodingType',
      'unsigned char* pbCertEncoded',
      'unsigned long cbCertEncoded',
      'void* pCertInfo',
      'uintptr_t hCertStore',
    ]

    class Ctx
      def crt
        OpenSSL::X509::Certificate.new pbCertEncoded[0, cbCertEncoded]
      end
    end

    def self.each
      store = CertOpenSystemStoreA 0, 'ROOT'
      ctx = nil
      yield Ctx.new(ctx).crt until (ctx = CertEnumCertificatesInStore store, ctx).null?
    ensure
      CertCloseStore store, 0
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
  def self.save(path=self.path)
    names = {}
    hashes = {}
    seen = {}
    Crypt.each do |crt|
      id = OpenSSL::Digest::SHA1.new.digest crt.to_der
      next if seen[id]
      seen[id] = 1

      hash = "%08x" % crt.subject.hash
      names[name = "#{hash}.#{hashes[hash] ||= 0}"] = 1
      hashes[hash] += 1

      File.open File.join(path, name), 'w' do |f|
        f.puts <<-EOT
Subject: #{crt.subject}
Valid:   #{crt.not_before} - #{crt.not_after}
Saved:   #{Time.now} by #{self} v#{VERSION}
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
    ENV["SSL_CERT_DIR"] = path
  end

  def self.go!
    t = Thread.new{ save }
    t.abort_on_exception=true
    at_exit{t.join}
    inject
  end

  go! if On

end
