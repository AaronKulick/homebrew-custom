require 'formula'

class HPNOpenSSH < Formula
  homepage 'http://www.openssh.com/'
  url 'http://ftp5.usa.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-6.2p2.tar.gz'
  version '6.2p2'
  sha1 'c2b4909eba6f5ec6f9f75866c202db47f3b501ba'

  option 'with-brewed-openssl', 'Build with Homebrew OpenSSL instead of the system version'
  option 'with-keychain-support', 'Add native OS X Keychain and Launch Daemon support to ssh-agent'
  option 'with-gssapi-support', 'Add support to GSSAPI key exchange'

  depends_on 'openssl' if build.with? 'brewed-openssl'
  depends_on 'ldns' => :optional
  depends_on 'pkg-config' => :build if build.with? "ldns"

  conflicts_with 'openssh'

  def patches
    p = []
    p << 'https://raw.github.com/AaronKulick/homebrew-custom/master/Patches/openssh-6.2p2/openssh-6.2p2-hpn14v1.patch'
    p << 'https://raw.github.com/AaronKulick/homebrew-custom/master/Patches/openssh-6.2p2/openssh-6.2p2-gsskex.patch' if build.with? 'gssapi-support'
    p << 'https://raw.github.com/AaronKulick/homebrew-custom/master/Patches/openssh-6.2p2/openssh-6.2p2-keychain.patch' if build.with? 'keychain-support'

    p
  end

  def install
    if build.include? "with-keychain-support"
        ENV.append "CPPFLAGS", "-D__APPLE_LAUNCHD__ -D__APPLE_KEYCHAIN__"
        ENV.append "LDFLAGS", "-framework CoreFoundation -framework SecurityFoundation -framework Security"
    end

    args = %W[
      --with-libedit
      --with-kerberos5
      --prefix=#{prefix}
      --sysconfdir=#{etc}/ssh
    ]

    args << "--with-ssl-dir=#{Formula.factory('openssl').opt_prefix}" if build.with? 'brewed-openssl'
    args << "--with-ldns" if build.with? "ldns"

    # Sometimes when Apple ships security update, the libraries get
    # updated while the headers don't. Disable header/library version
    # check when using system openssl to cope with this situation.
    args << "--without-openssl-header-check" if not build.with? 'brewed-openssl'

    system "./configure", *args
    system "make"
    system "make install"
  end

  def caveats
    if build.include? "with-keychain-support"
      <<-EOS.undent
        For complete functionality, please modify:
          /System/Library/LaunchAgents/org.openbsd.ssh-agent.plist

        and change ProgramArugments from
          /usr/bin/ssh-agent
        to
          #{HOMEBREW_PREFIX}/bin/ssh-agent

        After that, you can start storing private key passwords in
        your OS X Keychain.
      EOS
    end
  end
end
