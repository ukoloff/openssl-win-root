require 'ffi'

module Crypt
  extend FFI::Library
  ffi_lib 'crypt32'
  ffi_convention :stdcall

  attach_function :open, :CertOpenSystemStoreA, [:pointer, :string], :pointer
  attach_function :close, :CertCloseStore, [:pointer, :uint], :int
  attach_function :enum, :CertEnumCertificatesInStore, [:pointer, :pointer], :pointer

  def self.run
    store = open(nil, 'ROOT')
    p store
    ctx = nil
    begin
      while true
        ctx = enum store, ctx
        break if ctx.null?
        p ctx
      end
    ensure
      close store, 0
    end
  end

  run

end
