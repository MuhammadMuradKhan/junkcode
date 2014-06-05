# Fix wrong fs context for mod_security
/usr/sbin/semanage fcontext -a -t httpd_var_lib_t "/var/lib/mod_security(/.*)?"
#mlogc
/usr/sbin/semanage fcontext -a -t httpd_log_t "/var/log/mlogc(/.*)?"

/sbin/restorecon -Rv /var/lib/mod_security

