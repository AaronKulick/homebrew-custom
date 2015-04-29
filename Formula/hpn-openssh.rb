require "formula"

class HpnOpenssh < Formula
  homepage "http://www.openssh.com/"
  url "http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-6.8p1.tar.gz"
  version "6.8p1"
  sha256 "3ff64ce73ee124480b5bf767b9830d7d3c03bbcb6abe716b78f0192c37ce160e"

  option "with-keychain-support", "Add native OS X Keychain and Launch Daemon support to ssh-agent"

  depends_on "autoconf" => :build if build.with? "keychain-support"
  depends_on "openssl"
  depends_on "ldns" => :optional
  depends_on "pkg-config" => :build if build.with? "ldns"

  conflicts_with "openssh", :because => "provides alternative openssh"

  patch do
    url "http://downloads.sourceforge.net/project/hpnssh/HPN-SSH%2014.5%206.6p1/openssh-6.6p1-hpnssh14v5.diff.gz?r=&ts=1430322871&use_mirror=hivelocity"
    sha256 "682b4a6880d224ee0b7447241b684330b731018585f1ba519f46660c10d63950"
  end

  if build.with? "keychain-support"
    patch do
      url "https://trac.macports.org/export/135165/trunk/dports/net/openssh/files/0002-Apple-keychain-integration-other-changes.patch"
      sha256 "bcc9b9103fe2333ec6053fcdf5aac51ca2f07138cd05b66c37c01c92585ed778"
    end
  end

  patch do
    url "https://gist.githubusercontent.com/jacknagel/e4d68a979dca7f968bdb/raw/f07f00f9d5e4eafcba42cc0be44a47b6e1a8dd2a/sandbox.diff"
    sha256 "82c287053eed12ce064f0b180eac2ae995a2b97c6cc38ad1bdd7626016204205"
  end

  # Patch for SSH tunnelling issues caused by launchd changes on Yosemite
  patch do
    url "https://trac.macports.org/export/135165/trunk/dports/net/openssh/files/launchd.patch"
    sha256 "02e76c153d2d51bb0b4b0e51dd7b302469bd24deac487f7cca4ee536928bceef"
  end

  def install
    system "autoreconf -i" if build.with? "keychain-support"

    if build.with? "keychain-support"
      ENV.append "CPPFLAGS", "-D__APPLE_LAUNCHD__ -D__APPLE_KEYCHAIN__"
      ENV.append "LDFLAGS", "-framework CoreFoundation -framework SecurityFoundation -framework Security"
    end

    ENV.append "CPPFLAGS", "-D__APPLE_SANDBOX_NAMED_EXTERNAL__"

    args = %W[
      --with-libedit
      --with-pam
      --with-kerberos5
      --prefix=#{prefix}
      --sysconfdir=#{etc}/ssh
      --with-ssl-dir=#{Formula["openssl"].opt_prefix}
    ]

    args << "--with-ldns" if build.with? "ldns"

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  def caveats
    if build.with? "keychain-support" then <<-EOS.undent
        NOTE: replacing system daemons is unsupported. Proceed at your own risk.

        For complete functionality, please modify:
          /System/Library/LaunchAgents/org.openbsd.ssh-agent.plist

        and change ProgramArguments from
          /usr/bin/ssh-agent
        to
          #{HOMEBREW_PREFIX}/bin/ssh-agent

        You will need to restart or issue the following commands
        for the changes to take effect:

          launchctl unload /System/Library/LaunchAgents/org.openbsd.ssh-agent.plist
          launchctl load /System/Library/LaunchAgents/org.openbsd.ssh-agent.plist

        Finally, add  these lines somewhere to your ~/.bash_profile:
          eval $(ssh-agent)

          function cleanup {
            echo "Killing SSH-Agent"
            kill -9 $SSH_AGENT_PID
          }

          trap cleanup EXIT

        After that, you can start storing private key passwords in
        your OS X Keychain.
      EOS
    end
  end
end
