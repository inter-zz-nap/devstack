Getting Started With XCP 1.1 and Devstack
===============================================
The purpose of the code in this directory it to help developers bootstrap
a XCP 1.1 + Openstack development environment.  This file gives
some pointers on how to get started.

**These instructions have only been tested with OpenStack trunk as of February 3rd, 2012**

Step 1: Install XCP
------------------------
Install XCP 1.1 on a clean box. You can download XCP 1.1 at 
http://xen.org/download/xcp/index_1.1.0.html 

**Be sure to choose "thin provisioning" when when installing your server.**

Here are some sample XCP network settings for when you are just
getting started:

* XCP Host IP: 192.168.1.10
* XCP Netmask: 255.255.255.0
* XCP Gateway: 192.168.1.1
* XCP DNS: 192.168.1.1

**You must use static a static IP on your XCP host, not DHCP.**
**On XCP, DHCP does not work in bridge mode**

Step 2: Disable Openvswitch and Reboot
--------------------------------------

You now must change the XCP switch backend from Openvswitch to iptables. *The current Nova code does not work with Openvswitch as of February 3rd, 2012*.

    [root@xcp ~]# xe-switch-network-backend bridge
    Cleaning up old ifcfg files
     Remove... ifcfg-eth0
     Remove... ifcfg-eth0.100
     Remove... ifcfg-eth0.101
     Remove... ifcfg-eth1
     Remove... ifcfg-xapi1
     Remove... ifcfg-xapi2
     Remove... ifcfg-xenbr0
     Remove... ifcfg-xenbr1
    Disabling openvswitch daemon
    Configure system for bridge networking
    You *MUST* now reboot your system

Obey XCP and reboot your server.

Step 3: Prepare Dom0
-------------------
At this point, your server is missing some critical software that you will
need to run devstack (like git).  Do this to install required software:

    wget --no-check-certificate https://github.com/cloudbuilders/devstack/raw/xen/tools/xen/prepare_dom0.sh
    chmod 755 prepare_dom0.sh
    ./prepare_dom0.sh

This script will also clone devstack in /root/devstack

Step 4: Configure your localrc
-----------------------------
Devstack uses a localrc for user-specific configuration.  Note that
the XENAPI_PASSWORD must be your dom0 root password.
Of course, use real passwords if this machine is exposed.

    cat > /root/devstack/localrc <<EOF
    MYSQL_PASSWORD=my_super_secret
    SERVICE_TOKEN=my_super_secret
    ADMIN_PASSWORD=my_super_secret
    RABBIT_PASSWORD=my_super_secret
    # This is the password for your guest (for both stack and root users)
    GUEST_PASSWORD=my_super_secret
    # IMPORTANT: The following must be set to your dom0 root password!
    XENAPI_PASSWORD=my_super_secret
    # Do not download the usual images yet!
    IMAGE_URLS=""
    # Explicitly set virt driver here
    VIRT_DRIVER=xenserver
    # Explicitly set multi-host
    MULTI_HOST=1
    # Give extra time for boot
    ACTIVE_TIMEOUT=45
    EOF

Step 5: Run ./build_xva.sh
--------------------------
This script creates the base Xen all-in-one image.  This script can be run
on another machine if your dom0 does not have enough free disk space.

**If you want to run this script in dom0 for convenience, edit ../../stackrc and change all the "http://" references to "git://" so the devstack source will download properly**

Step 6: Run ./build_domU.sh
--------------------------
This script does a lot of stuff, it is probably best to read it in its entirety.
But in a nutshell, it performs the following:

* Configures bridges and vlans for public, private, and management nets
* Creates and installs a OpenStack all-in-one domU in an HA-FlatDHCP configuration
* A script to create a multi-domU (ie. head node separated from compute) configuration is coming soon!

**Note**: The default script uploads an image into the Glance repository that lacks the OpenStack guest agent. As such, any instance created with that image will take unusually long to BUILD (as it will wait to contact the agent). Uploading an image with the correct agent will rectify this problem.

Step 5: Do cloudy stuff!
--------------------------

To use the image, ssh into the newly created domU and source the openrc file:

    stack@ALLINONE:~$ **cd devstack/**
    stack@ALLINONE:~/devstack$ **source openrc**

Then start using the nova client to start images:

    stack@ALLINONE:~/devstack$ nova boot --image 8833315e-eea6-46a6-8961-aa3c44baf112 --flavor 1 ken
    +-------------------+----------------------------------------------------------+
    |      Property     |                          Value                           |
    +-------------------+----------------------------------------------------------+
    | OS-DCF:diskConfig | MANUAL                                                   |
    | accessIPv4        |                                                          |
    | accessIPv6        |                                                          |
    | adminPass         | TnLdZhAsrvV6                                             |
    | config_drive      |                                                          |
    | created           | 2012-02-03T22:20:04Z                                     |
    | flavor            | m1.tiny                                                  |
    | hostId            | c1ab944915eece52b83b383d4567f5cb557a46e15b809b0704fa33b9 |
    | id                | 689d5fd3-c05c-44f1-a14b-253067b2e3d8                     |
    | image             | tty                                                      |
    | key_name          |                                                          |
    | metadata          | {}                                                       |
    | name              | ken                                                      |
    | progress          | None                                                     |
    | status            | BUILD                                                    |
    | tenant_id         | 890518b296a74237a47d4cb24e16da8d                         |
    | updated           | 2012-02-03T22:20:05Z                                     |
    | user_id           | 819e5c6d0f8743f9b52914c28e841f0b                         |
    +-------------------+----------------------------------------------------------+
    stack@ALLINONE:~/devstack$ nova list
    +--------------------------------------+------+--------+------------------+
    |                  ID                  | Name | Status |     Networks     |
    +--------------------------------------+------+--------+------------------+
    | 689d5fd3-c05c-44f1-a14b-253067b2e3d8 | ken  | BUILD  | private=10.0.0.5 |
    +--------------------------------------+------+--------+------------------+
    stack@ALLINONE:~/devstack$

* Play with horizon
* Play with the CLI
* Log bugs to devstack and core projects, and submit fixes!
