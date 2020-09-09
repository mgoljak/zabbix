#!/usr/bin/python
import xmlrpclib
from pyzabbix import ZabbixAPI
import re
import sys
import argparse
import subprocess
from StringIO import StringIO
import syslog

syslog.syslog('Processing started')
parser = argparse.ArgumentParser()
requiredNamed = parser.add_argument_group('Required named arguments')
requiredNamed.add_argument('--glpi_url', help='GLPI url', required=True)
requiredNamed.add_argument('--glpi_username', help='GLPI username', required=True)
requiredNamed.add_argument('--glpi_password', help='GLPI password', required=True)
requiredNamed.add_argument('--zabbix_url', help='Zabbix url', required=True)
requiredNamed.add_argument('--zabbix_username', help='Zabbix username', required=True)
requiredNamed.add_argument('--zabbix_password', help='Zabbix password', required=True)

args = vars(parser.parse_args())
glpi_url = args['glpi_url']
glpi_username = args['glpi_username']
glpi_password = args['glpi_password']
zabbix_url = args['zabbix_url']
zabbix_username = args['zabbix_username']
zabbix_password = args['zabbix_password']

if glpi_url[-1] == '/':
    glpi_url = glpi_url[:-1]

server_url = glpi_url + '/plugins/webservices/xmlrpc.php'
server = xmlrpclib.ServerProxy(server_url)

try:
    result = server.glpi.doLogin({'login_name': glpi_username, 'login_password': glpi_password})
except Exception, err:
    syslog.syslog('ERROR: ' + str(err))
    result = None
    sys.exit(0)

session = result['session']

glpi_users = server.glpi.listUsers({'session': session, 'limit': 10000})    # all the users in glpi
glpi_groups = server.glpi.listGroups({'session': session, 'limit': 10000})  # all the groups in glpi
glpi_hosts = server.glpi.listObjects({'session': session, 'limit': 10000, 'itemtype': 'Computer'})  # all the computers
glpi_computertypes = server.glpi.listDropdownValues({'session': session, 'dropdown': 'ComputerType'})

computertypes_list = [t['name'] for t in glpi_computertypes]

# All the groups with associated users
glpi_groups_with_users = dict()
for item in glpi_groups:
    usrgr = server.glpi.listUsers({'session': session, 'limit': 10000, 'group': item['id']})
    glpi_groups_with_users[item['name']] = [d.get('name', None) for d in usrgr]

# Computers detailed data
glpi_computers = list()
for item in glpi_hosts:
    comp = server.glpi.getObject({'session': session, 'id': item['id'], 'show_name': 1, 'itemtype': 'Computer'})
    glpi_computers.append(comp)

server.glpi.doLogout({'session': session})

# Keeping only users with @srce.hr:
glpi_users[:] = [d for d in glpi_users if 'srce.hr' in d.get('name')]

# Associated groups for every user
glpi_users_with_groups = dict()
for item in glpi_users:
    glpi_users_with_groups[item['name']] = \
        [key for key, value in glpi_groups_with_users.items() if item['name'] in value]

# Keeping only usergroups with users in it
glpi_usergroups_unique = set()
for key, value in glpi_users_with_groups.items():
    for item in value:
        glpi_usergroups_unique.add(item)
glpi_usergroups_unique = list(glpi_usergroups_unique)

if zabbix_url[-1] == '/':
    zabbix_url = zabbix_url[:-1]

zabbix_server = zabbix_url + '/api_jsonrpc.php'

zapi = ZabbixAPI(zabbix_server)
try:
    zapi.login(zabbix_username, zabbix_password)
except Exception, err:
    syslog.syslog('ERROR: ' + str(err))
    sys.exit(0)

# Loading data from Zabbix
zabbix_hostgroup = zapi.hostgroup.get()
zabbix_users = zapi.user.get(output='extend')
zabbix_usergroup = zapi.usergroup.get(selectRights=1)   # all usergroups on Zabbix
zabbix_host = zapi.host.get()  # all the hosts on Zabbix

# Getting usergroup id for group "Guests"...
guestid = [d.get('usrgrpid') for d in zabbix_usergroup if d.get('name') == 'Guests']

dummy = None    # dummy variable used to tell if "Guests" usergroup needs to be updated

# List of hostgroups in GLPI (unique) - check if hosts exist in Zabbix
glpi_hostgroups_unique = set()  # hostgroups of hosts that exist on Zabbix
glpi_hosts_zabbix = list()     # glpi hosts that exist on zabbix
for item in glpi_computers:
    if any(d.get('name', None) == item['name'] for d in zabbix_host):
        glpi_hosts_zabbix.append(item)
        if 'computertypes_name' in item.keys():
            glpi_hostgroups_unique.add(item['computertypes_name'])
        if 'groups_name' in item.keys():
            glpi_hostgroups_unique.add(item['groups_name'])
        if 'groups_name_tech' in item.keys():
            glpi_hostgroups_unique.add(item['groups_name_tech'])
glpi_hostgroups_unique = list(glpi_hostgroups_unique)


newly_created_hostgroup = list()
# Creating hostgroups (only for hosts existing on Zabbix)...
for item in glpi_hostgroups_unique:
    # If hostgroup does not exist on Zabbix, create it
    if not any(d.get('name', None) == item for d in zabbix_hostgroup):
        zapi.hostgroup.create(name=item)
        newly_created_hostgroup.append(item)
        dummy = 1

# Update zabbix_hostgroup
zabbix_hostgroup = zapi.hostgroup.get()

# Connecting hosts to hostgroups...
glpi_group_pattern = re.compile('\d{3}-\d{2}-\d{3}')
for item in glpi_hosts_zabbix:
    zabbix_host_id = [d.get('hostid') for d in zabbix_host if d.get('name') == item['name']]
    zabbix_host_id = zabbix_host_id[0]
    glpi_hostgroup = set()
    if 'groups_name' in item.keys():
        glpi_hostgroup.add(item['groups_name'])
    if 'groups_name_tech' in item.keys():
        glpi_hostgroup.add(item['groups_name_tech'])
    if 'computertypes_name' in item.keys():
        glpi_hostgroup.add(item['computertypes_name'])
    if not glpi_hostgroup:
        continue
    else:
        zabbix_hostgroup_with_host = zapi.hostgroup.get(hostids=zabbix_host_id)
        zabbix_hostgroup_names = set()
        for j in zabbix_hostgroup_with_host:
            zabbix_hostgroup_names.add(j['name'])

        update = list(glpi_hostgroup.union(zabbix_hostgroup_names))
        if update != zabbix_hostgroup_names:
            zabbix_hostgroup_update = list()
            for i in update:
                if i in computertypes_list and i not in glpi_hostgroup or \
                        re.match(glpi_group_pattern, i) and i not in glpi_hostgroup:
                    pass
                else:
                    x2 = [d.get('groupid') for d in zabbix_hostgroup if d.get('name') == i]
                    if x2:
                        zabbix_hostgroup_update.append(x2[0])
            zapi.host.update(hostid=zabbix_host_id, groups=zabbix_hostgroup_update)

# If hostgroups are empty, remove them:
zabbix_hostgroup_containing_hosts = zapi.hostgroup.get(real_hosts=1)
# Group 'Templates' is also in hostgroups
zabbix_hostgroup_containing_hosts.append([d for d in zabbix_hostgroup if d.get('name') == 'Templates'][0])
zabbix_hostgroup_containing_hosts.append([d for d in zabbix_hostgroup if d.get('name') == 'Hypervisors'][0])
zabbix_hostgroup_containing_hosts.append([d for d in zabbix_hostgroup if d.get('name') == 'Virtual machines'][0])
zabbix_hostgroup_not_containing_hosts = [d for d in zabbix_hostgroup if d not in zabbix_hostgroup_containing_hosts]
if zabbix_hostgroup_not_containing_hosts:
    for item in zabbix_hostgroup_not_containing_hosts:
        zapi.hostgroup.delete(groupid=item['groupid'])

# If there has been new hostgroups created, update usergroups with appropriate permissions
if dummy:
    # Update zabbix_hostgroup
    zabbix_hostgroup = zapi.hostgroup.get()
    # Updating usergroups with same name as newly created hostgroup (if exists)
    for item in newly_created_hostgroup:
        usrid = [d.get('usrgrpid') for d in zabbix_usergroup if d.get('name') == item]
        grpid = [d.get('groupid') for d in zabbix_hostgroup if d.get('name') == item]
        if usrid:
            zapi.usergroup.update(usrgrpid=usrid[0], rights={'permission': 3, "id": grpid[0]})

# Checking if 'Guest' usergroup needs updating...
guestrights = [d.get('rights') for d in zabbix_usergroup if d.get('name') == 'Guests'][0]
guestgroupid = set()
for item in guestrights:
    guestgroupid.add(item['id'])

hostgroupids = set([d.get('groupid') for d in zabbix_hostgroup])
if not guestgroupid == hostgroupids:
    Guest_rights = list()
    for i in hostgroupids:
        Guest_rights.append({"permission": 2, "id": i})
    zapi.usergroup.update(usrgrpid=guestid[0], rights=Guest_rights)


# Creating usergroups...
for item in glpi_usergroups_unique:
    # If usergroup does not exist on Zabbix, create it
    if not any(d.get('name', None) == item for d in zabbix_usergroup):
        hostgrpid = [d.get('groupid') for d in zabbix_hostgroup if d.get('name') == item]
        if hostgrpid:
            zapi.usergroup.create(name=item, rights={"permission": 3, "id": hostgrpid[0]})
        else:
            zapi.usergroup.create(name=item)

# Creating users and updating existing users...
for key, value in glpi_users_with_groups.items():
    if not any(d.get('alias', None) == key for d in zabbix_users):
        name = [d.get('firstname') for d in glpi_users if key == d.get('name')]
        if name:
            name = name[0]
        else:
            name = ''
        surname = [d.get('realname') for d in glpi_users if key == d.get('name')]
        if surname:
            surname = surname[0]
        else:
            surname = ''
        grpid = list()
        for item in value:
            x = [d.get('usrgrpid') for d in zabbix_usergroup if item == d.get('name')]
            if x:
                grpid.append(x[0])
        grpid.append(guestid[0])  # all the users are members of 'Guests' usergroup
        if grpid == guestid:
            usertype = 1    # Zabbix user
        else:
            usertype = 2    # Zabbix admin
        zapi.user.create(alias=key, passwd='', usrgrps=grpid, name=name, surname=surname, type=usertype)
    else:
        usrid = [d.get('userid') for d in zabbix_users if key == d.get('alias')][0]
        # Check if name and surname are equal in GLPI and Zabbix:
        glpi_name = [d.get('firstname') for d in glpi_users if key == d.get('name')]
        if glpi_name:
            glpi_name = glpi_name[0]
        zabbix_name = [d.get('name') for d in zabbix_users if key == d.get('alias')][0]
        if glpi_name != zabbix_name:
            zapi.user.update(userid=usrid, name=glpi_name)
        glpi_surname = [d.get('realname') for d in glpi_users if key == d.get('name')]
        if glpi_surname:
            glpi_surname = glpi_surname[0]
        zabbix_surname = [d.get('surname') for d in zabbix_users if key == d.get('alias')][0]
        if glpi_surname != zabbix_surname:
            zapi.user.update(userid=usrid, surname=glpi_surname)
        usrgrp = zapi.usergroup.get(userids=usrid)
        usrgrpset = set()
        for i in usrgrp:
            usrgrpset.add(i['name'])
        if not value:
            value = ['Guests']
        if not set(value).issubset(usrgrpset):
            usrgrplist = list(set(value).union(usrgrpset))
            usrgrpids = list()
            for item in usrgrplist:
                x1 = [d.get('usrgrpid') for d in zabbix_usergroup if d.get('name') == item]
                if x1:
                    usrgrpids.append(x1[0])
            usrtype = [d.get('type') for d in zabbix_users if d.get('alias') == key][0]
            if usrtype == '3':
                zapi.user.update(userid=usrid, usrgrps=usrgrpids)
            else:
                if len(usrgrplist) > 1:
                    zapi.user.update(userid=usrid, usrgrps=usrgrpids, type=2)
                else:
                    zapi.user.update(userid=usrid, usrgrps=usrgrpids, type=1)

# Default Zabbix users
defaultusersalias = ['guest', 'apiuser', 'nagios', 'Admin']
default_users = [d for d in zabbix_users if d.get('alias') in defaultusersalias]
SuperAdmin = [d for d in zabbix_users if d.get('type') == '3']
default_users = default_users + SuperAdmin

# Remove users from Zabbix which don't exist on GLPI (except the default ones)
nonglpiusers = list()
for item in zabbix_users:
    if not any(d.get('name', None) == item['alias'] for d in glpi_users) and item not in default_users:
        zapi.user.delete(item['userid'])


# Update usergroups
zabbix_usergroup = zapi.usergroup.get(selectUsers=1)   # updating usergroups

# Default Zabbix usergroups
defaultusergroupname = ['Guests', 'API', 'Debug', 'Disabled', 'No access to the frontend']
default_usergroups = [d for d in zabbix_usergroup if d.get('name') in defaultusergroupname]


# If usergroup is empty, remove it
for item in zabbix_usergroup:
    if not item['users'] and item not in default_usergroups:
        zapi.usergroup.delete(item['usrgrpid'])

zapi.user.logout()

# End message with update info:
end_msg = 'OK!'
syslog.syslog(end_msg)

# SENDING DATA TO ZABBIX

# Path to zabbix_sender, conf file and file with data
zabbix_sender = '/usr/bin/zabbix_sender'
zabbix_confd = '/etc/zabbix/zabbix_agentd.conf'

# Storing stdout in a variable...
old_stdout = sys.stdout
result = StringIO()
save_stdout = sys.stdout
sys.stdout = result
print('- glpi.hosts_total ' + str(len(glpi_computers)))
print('- glpi.hosts_synced ' + str(len(glpi_hostgroups_unique)))
print('- glpi.users ' + str(len(glpi_users)))
print('- glpi.groups ' + str(len(glpi_groups)))
print('- glpi.usergroups ' + str(len(glpi_usergroups_unique)))
print('- glpi.sensor ' + str(end_msg))
sys.stdout = save_stdout
result_string = result.getvalue()

# Executing external zabbix_sender binary...
try:
    p = subprocess.Popen([zabbix_sender, '-c', zabbix_confd, '-i', '-'], stdout=subprocess.PIPE, stdin=subprocess.PIPE)
    p2 = p.communicate(input=result_string)[0]
except Exception, e2:
    syslog.syslog('zabbix_sender_ERROR: ' + str(e2))
    sys.exit(0)
