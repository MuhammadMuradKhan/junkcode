#!/bin/sh
####################
# Date: Fri May 30 17:13:48 CEST 2014
# Version : 1.1
# Author: Damfino
# 
# Fix wrong fs context for Oracle Web Gate
/usr/sbin/semanage fcontext -a -t httpd_tmp_t "/opt/netpoint/webgate/access(/.*)?"
/usr/sbin/semanage fcontext -a -t bin_t "/opt/netpoint/webgate(/.*)?bin(/.*)?"
#
/usr/sbin/semanage fcontext -a -t httpd_var_run_t "/opt/netpoint/webgate/access/oblix/config/random-seed"
# Text Relocation
/usr/sbin/semanage fcontext -a -t textrel_shlib_t "/opt/netpoint/webgate/access/_jvmWebGate(/.*)?/.*\.so(\.[^/]*)*"
# shared lib
/usr/sbin/semanage fcontext -a -t textrel_shlib_t "/opt/netpoint/webgate/access/oblix/lib/.+\.so(\.[^/]*)*"
/usr/sbin/semanage fcontext -a -t textrel_shlib_t "/opt/netpoint/opt/netpoint./webgate/access/oblix/apps/webgate/bin/.+\.so(\.[^/]*)*"
/usr/sbin/semanage fcontext -a -t textrel_shlib_t "/opt/netpoint/webgate/access/oblix/apps/webgate/bin/.+\.so(\.[^/]*)*"
# log file
/usr/sbin/semanage fcontext -a -t httpd_log_t "/opt/netpoint/webgate/access/oblix/logs(/.*)?"
# lock file
/usr/sbin/semanage fcontext -a -t httpd_var_run_t "/opt/netpoint/webgate(/.*)?/.*\.lck"
# conf file
/usr/sbin/semanage fcontext -a -t httpd_config_t "/opt/netpoint/webgate/access/oblix/config(/.*)?"
# lock file
#/usr/sbin/semanage fcontext -a -t httpd_var_run_t "/opt/netpoint/webgate/access/oblix/config/.*\.lck"
# cgi
/usr/sbin/semanage fcontext -a -t httpd_sys_script_exec_t "/opt/netpoint/webgate/access/oblix/lang/en-us/securid-cgi(/.*)?"
# auth plugin
/usr/sbin/semanage fcontext -a -t textrel_shlib_t "/etc/httpd/WLSPlugin11.*(/.*)?/lib/.*\.so(\.[^/]*)*"

# boolean

setsebool -P httpd_execmem 1

setsebool -P httpd_can_network_connect 1

#Port contexts
#Allow Apache to listen on tcp port
cat <<EOF >/tmp/adjwebgate.sh.$$
30028
30030
20207
20047
30032
30000
20048
30001
20049
30002
30003
30035
30004
30005
30037
30006
30038
30070
30007
30039
30008
30040
30042
30010
30011
30044
30012
30013
30046
30014
30015
30016
30017
30113
30114
30018
30019
30020
20200
20009
30026
6666
EOF
while read _port
do
semanage port -a -t http_port_t -p tcp "${_port}"
done < /tmp/adjwebgate.sh.$$
rm -f /tmp/adjwebgate.sh.$$

/sbin/restorecon -Rv /opt/netpoint/webgate

/sbin/restorecon -Rv /etc/httpd

