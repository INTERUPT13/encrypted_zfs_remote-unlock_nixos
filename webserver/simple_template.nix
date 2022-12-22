# TODO make this system more advanced by allowing the user to
 # call this function with more complex data structure that
 # then get applied to the end. As for now he can only pass
 # a list and lotsa stuff is hardcoded
{lib,domains,...}: with lib;{
  services.nginx = {
    enable = true;

    virtualHosts = listToAttrs
      (forEach domains (domain: {
        name = "${domain}";
        value = {
          forceSSL = true;
          sslCertificate    = "/var/lib/acme/${domain}/cert.pem";
          sslCertificateKey = "/var/lib/acme/${domain}/key.pem";
          locations."/" = {
            root = "/var/www/${domain}/";
          };
        };
      }));
  };





            #security.acme.certs = {
            #  "..." = {
            #    webroot = "/var/lib/acme/.challenges";
            #    email = "....";
            #    group = "nginx";
            #  };
            #};
}
