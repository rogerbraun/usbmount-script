#!/home/roger/.rbenv/versions/1.9.3-p327/bin/ruby
# General setup
#
Dir.mkdir "/tmp/usbmount" if !File.exists?("/tmp/usbmount")
Dir.mkdir "/media/usbmount" if !File.exists?("/media/usbmount")

def unmount_all
  mounted_drives = Dir.glob("/tmp/usbmount/*.mount")
  mounted_drives.each do |drive|
    drive_path = "/dev/disk/by-id/#{File.basename(drive, ".mount")}"
    puts "Unmounting #{drive_path}"
    error = `umount #{drive_path}`
    if $?.exitstatus == 0
      puts "Unmounted!"
      File.delete(drive)
    else
      puts "Something went wrong..."
      puts "Umount said:"
      puts error
    end
  end
end

def mount_all
  drives = Dir.glob("/dev/disk/by-id/usb*-part*")

  drives.each do |drive|
    basename = File.basename drive
    mountdir = "/media/usbmount/#{basename}"
    mountfile = "/tmp/usbmount/#{basename}.mount"

    info = `blkid #{drive}`
    if info[/crypto/] 
      puts "#{drive} is encrypted, skipping..."
      next
    end

    if File.exists? mountfile
      puts "Already mounted or info file present: #{mountfile}"
    else
      Dir.mkdir mountdir if !File.exists? mountdir
      `mountpoint #{mountdir}`
      if $?.exitstatus == 0
        puts "Something already mounted at #{mountdir}, but I don't know about it."
      else
        mf = open mountfile, "w"
        mf.puts mountdir
        mf.close
        puts "Mounting #{drive} at #{mountdir}"
        error = `mount -o gid=users,fmask=113,dmask=002 #{drive} #{mountdir}`
        if $?.exitstatus == 0
          puts "Mounted!"
        else
          puts "Something went wrong..."
          puts "Mount said:"
          puts error
        end
      end
    end
  end
end

if ARGV.length == 0
  mount_all
end

if ARGV.length == 1
  if ARGV[0] == "mount"
    mount_all
  end
  if ARGV[0] == "unmount"
    unmount_all
  end
end

