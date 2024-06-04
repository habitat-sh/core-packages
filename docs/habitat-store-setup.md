# Habitat Store Setup Instructions

### 1. Create a new APFS volume

**Command:**
```bash
/usr/sbin/diskutil apfs addVolume "disk3" "APFS" "Habitat Store" -nomount
```

**Explanation:**
This command creates a new APFS (Apple File System) volume named "Habitat Store" on the disk identified as `disk3`. The `-nomount` option ensures that the new volume is created but not mounted immediately. This is necessary because we want to mount it at a specific mount point later.

### 2. Get the UUID of the new APFS volume

**Command:**
```bash
uuid=$(/System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -k <disk_id>)
```

**Explanation:**
This command retrieves the UUID (Universally Unique Identifier) of the newly created APFS volume. Replace `<disk_id>` with the appropriate disk identifier of your new volume (e.g., `disk3s1`). The UUID is stored in the variable `uuid` for later use.

### 3. Edit the `/etc/fstab` file to configure the volume

**Command:**
```bash
sudo vifs
```

**Explanation:**
This command opens the `/etc/fstab` file using `vifs`, a safe way to edit fstab entries. You need to add a new line to this file to configure the new volume.

**Lines to add in `/etc/fstab`:**
```
UUID=<uuid> /hab apfs rw,noauto,nobrowse,suid,owners
```

Replace `<uuid>` with the UUID obtained in the previous step. This entry configures the volume to be mounted at `/hab` with read/write permissions (`rw`), not to mount automatically (`noauto`), not to show in Finder (`nobrowse`), and to preserve suid and ownership (`suid,owners`).

### 4. Edit the `/etc/synthetic.conf` file

**Command:**
```bash
sudo vi /etc/synthetic.conf
```

**Explanation:**
This command opens the `/etc/synthetic.conf` file in the `vi` editor. This file is used to create synthetic mount points on macOS.

**Lines to add in `/etc/synthetic.conf`:**
```
hab
```

Add the line `hab` followed by a newline. This line instructs macOS to create a synthetic mount point at `/hab` on boot. The newline is crucial to prevent crashes.

### 5. Create synthetic objects on the root volume

**Command:**
```bash
{
    /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t || true # Big Sur
    /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -B || true # Catalina
} >/dev/null 2>&1
```

**Explanation:**
This command creates the synthetic objects on the root volume and saves us from having to reboot the system.

### 6. Mount the volume at the `/hab` mount point

**Command:**
```bash
sudo diskutil mount -mountPoint /hab <uuid>
```

**Explanation:**
This command mounts the APFS volume with the specified UUID at the `/hab` mount point. Replace `<uuid>` with the UUID obtained earlier.

## Common Issues

### Store Directory not mounting on /hab

After a system restart you may find that the /hab directory is no longer mounted. 
This will result in build failures if you attempt to build or run anything with habitat.

You may attempt to remount the disk to /hab using the command in step 6. 
This will show a message saying the volume is mounted but in reality, nothing happens.
This is because the Habitat Volume is already mounted automatically when the system rebooted.

You need to first unmount the volume and re-run the command from step 6.
To unmount the habitat volume you can use:

```bash
sudo diskutil unmount <uuid>
```