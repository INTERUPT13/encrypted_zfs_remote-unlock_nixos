# TODO make checks for login_accounts
{ config, pkgs, fqdn, domains, acme_email, loginAccounts, webmail_domain }:
with pkgs.lib; {
  mailserver = {
    enable = true;

    # is this like the primary domain the mailserver uses?
    inherit fqdn;
    # reverse DNS of the server ip must also point back to fqdn
    # test via nix-shell -p bind --command "host <ip>"
    # must point back fqdn EXACTLY

    # 1) domains listed here need an MX record so that domain.tld points
    # to domain.tld. check via:
    #   nix-shell -p bind --command "host-t mx domain.tld"
    # must return to domain.tld exactly

    # 2) domains listed here need an SPF record. It can look like "v=spf1 a:mail.domain.tld -all" (type = TXT)
    # can be checked via:
    #   nix-shell -p bind --command "host -t TXT domain.tld"
    # and should return:
    # domain.tld descrptive text "v=spf1 a:mail.domain.tld -all"

    # 3) domainslisted here need an DKIM sig record. It should look like "v=DKIM1; p=<long-key>" (type = TXT)
    # the key can be exctracted from /var/dkim/domain.tld.mail.txt
    # it can be checked via:
    #   nix-shell -p bind --command "host -t txt mail._domainkey.domain.tld"
    # "mail" from mail._domainkey does not stand for mail.domain.tld but instead is a selector
    # for some other stuff
    # it should return:
    #  "mail._domainkey.domain.tld descriptive text "v=DKIM1;p=<longass-key>"

    # 4) domains listed here need an DMARK record. It shouldlook like "v=DMARC1; p=none" (type = TXT)
    # can be checked like:
    #   nix-shell -p bind --command "host-t TXT _dmarc.domain.tld"
    # should return:
    #   _dmarc.domain.tld  descrptivetext "v=DMARC1; p=none"

    inherit domains;

    # specify cert location manually
    certificateScheme = 1;

    certificateFile = "/var/lib/acme/${fqdn}/cert.pem";
    keyFile = "/var/lib/acme/${fqdn}/key.pem";

    inherit loginAccounts;

  };

  # nginx virtual host setup so 

  # so it can access the files
  users.users.nginx.extraGroups = [ "acme" ];

  services.nginx = {

    #enable = true; TODO if its not alreay
    virtualHosts = listToAttrs (forEach (domains ++ [ fqdn ]) (domain: {
      name = "acmechallenges.${domain}";
      value = {
        serverName =
          domain; # otherwise it would use acmechallenges.${domain} which would later fail in the dns part
        locations."/.well-known/acme-challenge" = {
          root = "/var/lib/acme/.challenges";
        };
      };
    }));
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = acme_email;

  # TODO is there a point to checking if this cert is not defined elsewhere
  # like in the webserver configs already? I mean if the info mismatches
  # it will fail and if not it wont
  security.acme.certs = listToAttrs # TODO
    (forEach (domains ++ [ fqdn ]) (domain: {
      name = "${domain}";
      value = {
        webroot = "/var/lib/acme/.challenges";
        email = acme_email;
        group = "nginx";
      };
    }));

  services.roundcube = {
    enable = true;
    # V does not need to be fqdn. needs a dns record though ofc
    hostName = webmail_domain;
    extraConfig = ''
      # starttls needed for authentication, so the fqdn required to match
      # the certificate
      $config['smtp_server'] = "tls://${config.mailserver.fqdn}";
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
    '';
  };

}
