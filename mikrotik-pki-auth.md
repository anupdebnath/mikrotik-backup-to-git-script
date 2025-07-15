# Enabling MikroTik Password Less SSH Access to Remote Devices

If you manage a network with multiple MikroTik routers or Linux servers, setting up SSH key-based authentication allows you to automate tasks without the need for manual password entry. Here’s a step-by-step guide on configuring your MikroTik router passwordless SSH login to other devices.

## Step 1: Generate an SSH Key Pair and upload to MikroTik router

1. Unfortunately, MikroTik does not have an in-built command for SSH key generation, so we’ll use a Linux system to create your SSH key pair. Log into your Linux system and generate a new SSH key pair:

   ```bash
   ssh-keygen -t rsa -m PEM -f mikrotik_key -C "mikrotik device name"
   ```

   > MikroTik routers only support private keys in PEM or PKCS#8 format.

   This creates two files, `mikrotik_key` (private key) and `mikrotik_key.pub` (public key).

2. Next, copy both private and public key to the MikroTik router using SCP:

   ```bash
   scp mikrotik_key* user@mikrotik_ip:/
   ```

   Add `-p 1234` flag to SCP if you are using a custom port.

## Step 2: Importing private key for the particular user

The private key has to be added for the particular user.

1. Import the private key for the particular user, enter the following command:

   ```mikrotik
   /user ssh-keys private import user=username private-key-file=mikrotik_key
   ```

   Replace `username` with the actual MikroTik username.

## Step 3: Copy the Public Key to your devices

To enable passwordless access, add the public key (mikrotik_key.pub) to the authorized_keys file on each target device.

1.  For Linux devices, use SCP to copy the public key and append it to the authorized_keys file. On the target device, run:

    ```bash
    scp mikrotik_key.pub user@linux_device_ip:~/
    cat mikrotik_key.pub >> ~/.ssh/authorized_keys
    ```

2.  (**Optional**) For MikroTik routers, log into the target MikroTik and upload the public key file to the MikroTik router. Then log into the target router and run:

    ```mikrotik
    /user ssh-keys import user=admin public-key-file=mikrotik_key.pub
    ```

## Step 4: Test Password Less Access from MikroTik

From the MikroTik router, test SSH connections to other devices to confirm successful passwordless login:

```mikrotik
/system ssh address=target_device_ip user=username
```

If configured correctly, MikroTik will establish the connection without prompting for a password.

# Automate Tasks Using Scripts

Now that passwordless SSH is enabled, you can automate tasks by creating scripts on your MikroTik router that use SSH to run commands on other devices, allowing centralized management of tasks like configuration backups, log retrieval, and system monitoring.
