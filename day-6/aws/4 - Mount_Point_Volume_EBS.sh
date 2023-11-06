# SSH into the new EC2 Instance where the pod is running and become root
sudo su -

# List the block devices available
lsblk

# Check the type of data on the volume
file -s /dev/xvdaa
Note: Access the AWS Console to get this information(EC2 -> Volumes -> Column Attached Instances )

# Create a mount point, then mount the volume
mkdir -p /mnt/myClusterK8s
mount /dev/xvdaa /mnt/myClusterK8s -t ext4
ls -lha /mnt/myClusterK8s


