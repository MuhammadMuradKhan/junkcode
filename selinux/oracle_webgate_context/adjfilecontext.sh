# Fix wrong fs context for Oracle Web Gate
/usr/sbin/semanage fcontext -a -t httpd_tmp_t "/opt/netpoint/webgate/access(/.*)?" >/dev/null 2>&1 || :
/usr/sbin/semanage fcontext -a -t bin_t "/opt/netpoint/webgate(/.*)?bin(/.*)?"  >/dev/null 2>&1 || :
#
/usr/sbin/semanage fcontext -a -t httpd_var_run_t "/opt/netpoint/webgate/access/oblix/config/random-seed"
# Text Relocation
/usr/sbin/semanage fcontext -a -t textrel_shlib_t "/opt/netpoint/webgate/access/_jvmWebGate(/.*)?/.*\.so" >/dev/null 2>&1 || :
# shared lib
/usr/sbin/semanage fcontext -a -t textrel_shlib_t "/opt/netpoint/webgate/access/oblix/lib/.+\.so(\.[^/]*)*" >/dev/null 2>&1 || :
/usr/sbin/semanage fcontext -a -t textrel_shlib_t "/opt/netpoint/opt/netpoint./webgate/access/oblix/apps/webgate/bin/.+\.so(\.[^/]*)*" >/dev/null 2>&1 || :
/usr/sbin/semanage fcontext -a -t textrel_shlib_t "/opt/netpoint/webgate/access/oblix/apps/webgate/bin/.+\.so(\.[^/]*)*" >/dev/null 2>&1 || :
# log file
/usr/sbin/semanage fcontext -a -t httpd_log_t "/opt/netpoint/webgate/access/oblix/logs(/.*)?" >/dev/null 2>&1 || :
# lock file
/usr/sbin/semanage fcontext -a -t httpd_var_run_t "/opt/netpoint/webgate(/.*)?/.*\.lck" >/dev/null 2>&1 || :
# conf file
/usr/sbin/semanage fcontext -a -t httpd_config_t "/opt/netpoint/webgate/access/oblix/config(/.*)?" >/dev/null 2>&1 || :
# lock file
/usr/sbin/semanage fcontext -a -t httpd_var_run_t "/opt/netpoint/webgate/access/oblix/config/.*\.lck" >/dev/null 2>&1 || :
# cgi
/usr/sbin/semanage fcontext -a -t httpd_sys_script_exec_t "/opt/netpoint/webgate/access/oblix/lang/en-us/securid-cgi(/.*)?" >/dev/null 2>&1 || :
# auth plugin
/usr/sbin/semanage fcontext -a -t textrel_shlib_t "/etc/httpd/WLSPlugin11.*(/.*)?/lib/.*\.so"
# boolean

setsebool -P httpd_execmem 1

setsebool -P httpd_can_network_connect 1




/sbin/restorecon -Rv /opt/netpoint/webgate >/dev/null 2>&1 || :

/sbin/restorecon -Rv /etc/httpd >/dev/null 2>&1 || :

