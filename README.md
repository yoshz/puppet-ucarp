# ucarp

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with nimblestreamer](#setup)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module installs and configures ucarp on CentOS 7.

It allows you set up multiple virtual ip addresses with automatic failover by using ucarp.

## Setup

```bash
puppet module install yoshz-ucarp
```

## Usage

Add the module to node configuration:

```puppet
node /host*/ {
  class { '::ucarp':
    bind_interface => 'ens160', 
    password       => 'ProtectedPassword', 
  }
  ucarp::host { '001':
    bind_interface  => 'ens160', 
    vip_address     => '192.168.0.101',
    source_address  => '192.168.0.1',
    master_hostname => 'host001',
  }  
  ucarp::host { '002':
    bind_interface  => 'ens160', 
    vip_address     => '192.168.0.102',
    source_address  => '192.168.0.2',
    master_hostname => 'host002',
  }  
}
```

Or add the following hiera configuration to your host group

```yaml
ucarp::bind_interface: "ens160"
ucarp::password: ProtectedPassword
ucarp::hosts:
  '001':
    vip_address: 192.168.0.101
    master_hostname: host001
  '002':
    vip_address: 192.168.0.102
    master_hostname: host002
  '003':
    vip_address: 192.168.0.103
    master_hostname: host003
  '004':
    vip_address: 192.168.0.104
    master_hostname: host004
```

## Reference

### Parameters

#### `password`

Password used by all ucarp servers.
Can be set as parameter on `ucarp` as default for all hosts.

#### `bind_interface`

Network interface to bind the virtual ip address.
Can be set as parameter on `ucarp` as default for all hosts.

#### `vip_address`

Virtual ip address that is assigned by ucarp

#### `source_address`

The actual ip address of the current server.
Defaults to `$::ipaddress`.

#### `master_hostname`

The hostname of the master server that should have the virtual ip address assigned.
Defaults to `$::hostname`.


## Limitations

Only CentOS 7 is tested currently.

## Development

You are free to fork this repository and support to additional OS or configuration options.