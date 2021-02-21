# Catalina

This guide is based on OSX-KVM checked out at commit
bda4cc8e698356510c27747b7a929339f450890c.


> **NOTE**: All commands not run inside the macOS VM are expected to be run while inside the contained `nix-shell`.

## Diffs

The upstream OSX-KVM repo is patched to use our own qcow's and OVMF files.

## Installation

1. Follow the installation preparation steps from
[OSX-KVM](https://github.com/kholia/OSX-KVM/tree/bda4cc8e698356510c27747b7a929339f450890c#installation-preparation):
    * Run `./fetch-macOS.py` and select the latest version of Catalina
    * Run `qemu-img convert BaseSystem.dmg -O raw BaseSystem.img`
    * Run `qemu-img create -f qcow2 mac_hdd_ng.img 128G`
    * You may ignore the networking setup; our modified
    `./boot-macOS-Catalina.sh` script sets up user-mode networking instead
2. Run `./boot-macOS-Catalina.sh` and boot from the install disk (may take a while)
    * You will want a VNC client -- I used tigervnc's `vncviewer`
    and forwarded the VNC port to my local system with `ssh -L
    5900:localhost:5900 user@remote-machine-running-qemu` then
    `nix-shell -p tigervnc --run "vncviewer 127.0.0.1:5900"`
3. Select the "English" language
4. Select "Disk Utility"
5. Select the "QEMU HARDDISK Media" disk (around 130GB, "uninitialized")
6. Click "Erase" (in the top middle), set the Name to "system" (exactly;
case matters!), Format to "Mac OS Extended (Journaled)", and Scheme to
"GUID Partition Map"
7. Click "Erase" and then "Done"
8. Exit Disk Utility by clicking the red exit button at the top left
9. Select "Reinstall macOS" and click "Continue"
10. Click "Continue"
11. Click "Agree" and click "Agree" in the dialog that pops up
12. Select the "system" disk and click "Install"
    * This will take a bit of time (roughly 30 minutes, but may be more or less)
14. Once the install process gets to the "Welcome" screen where you select
a physical location, Ctrl-C the QEMU process and copy the disk image
(`mac_hdd_ng.img`) to another location for safe keeping. This duplicated
image will be used for future fresh re-setting-up like major upgrades.


15. Restart the VM with `./boot-macOS-Catalina.sh` and reconnect to VNC
    * Wait 3 seconds for macOS to automatically boot
16. Select "United States" and click "Continue"
17. Click "Continue" on the "Written and Spoken Languages" page
18. Click "Continue" on the "Data & Privacy" page
19. Select "Don't transfer any information now" (if it isn't already)
and click "Continue" on the "Transfer Information to This Mac" page
20. Click "Set Up Later" on the "Sign In with Your Apple ID" page
    * Confirm by clicking "Skip" on the dialog that pops up
21. Click "Agree" on the "Terms and Conditions" page
    * Confirm by clicking "Agree" on the dialog that pops up
22. Create a user:
    * Full name: `nixos`
    * Account name: `nixos`
    * Password: generate a new one each time, note: nixos is not a good password =)
      * NOTE: You will need to remember this
    * Hint: leave blank for no hint
23. Click "Customize Settings" on the "Express Set Up" page
24. Ensure the box next to "Enable Location Services on this Mac"
is unticked (disabled) on the "Enable Location Services" page
    * Confirm by clicking "Don't Use" on the dialog that pops up
25. Select your timezone: "UTC - United Kingdom" and click "Continue"
26. Ensure both boxes on the "Analytics" page are not ticked ("Share
Mac Analytics with Apple" was enabled by default -- untick that)
27. Click "Set Up Later" on the "Screen Time" page
28. Ensure the box next to "Enable Ask Siri" on the "Siri" page is
not ticked and click "Continue"
29. Click "Continue" on the "Choose Your Look" page
30. You'll reach the desktop where macOS will try to configure the
keyboard; click "Continue", press `z` and then `/`, make sure `ANSI`
is selected, and click "Done"
31. Set up Full Disk Access for the terminal:
    * Click the magnifying glass in the top bar (top right corner), search for "term", and press Enter on "Terminal"
    * Close the "Terminal" window
    * Click the Apple icon (top left)
    * Select "System Preferences" from the drop down
    * Click on "Security & Privacy"
    * Select the "Privacy" tab
    * Scroll down to "Full Disk Access" and select it
    * Click the lock icon on the bottom left, enter the password you set
    earlier, and click "Unlock" (or hit enter) to confirm
    * Click the "+" icon
    * In the window that opens up, search for "terminal" (search box is
    top right) and select "Name matches: terminal"
    * Then select the "Terminal" application under the "Today" header
      * **NOTE**: To ensure this is the right "Terminal" make sure the path displayed on the bottom of the window starts with "system" (the Name we defined when erasing the disk earlier) and not "macOS Base System"
    * Close that window by clicking the red close button on the top left
32. Open the "Terminal" again by clicking the magnifying glass in the top bar (top right corner), searching
for "term", and pressing Enter on "Terminal"
33. Run `sudo systemsetup -setremotelogin on` to turn on SSH.
    * IMPORTANT: DO NOT TEST SSH AT THIS STAGE! Testing SSH now would cause
    the image to generate an SSH host key, and cause it to be fixed in a
    generic disk image too soon.
34. Disable the protections preventing you from running unsigned software:
`sudo spctl --master-disable`
35. Enable automatically mounting ISOs, even before users log in: `sudo
defaults write /Library/Preferences/SystemConfiguration/autodiskmount
AutomountDisksWithoutUserLogin -bool YES`
36. Bypass new Catalina protections that prevent autorunning scripts from
`/Volumes`: `sudo ln -s /Volumes/CONFIG/apply.sh ~root/apply.sh`
37. Create an autorun script by writing the following contents to `/Library/LaunchDaemons/org.nixos.bootup.plist`:
    * You can curl the GitHub shortlink https://git.io/JtyI9 (which points to https://gist.githubusercontent.com/grahamc/126b1a28d50d99db315fb5b6fce551c7/raw/db5a95ca6b3002e3518fb5817437b4314e6f4085/catalina-----%2520org.nixos.bootup.plist) to prevent having to type this mess

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>org.nixos.bootup</string>
    <key>ProgramArguments</key>
    <array>
        <string>bash</string>
        <string>/var/root/apply.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>StartOnMount</key>
    <true/>
</dict>
</plist>
```

38. Close the terminal and select "Shut Down" from the Apple menu
39. Deselect "Reopen windows when logging back in" and click "Shut Down"
40. Duplicate `mac_hdd_ng.img` once more, to `mac_hdd_ng.configured.img`


This image is used as the basis for hydra and ofborg builders.

## Notes

* To generate a `config.iso` for use with the VM:

```shell
cd cdrom
ssh-keygen -A -f . # to generate host keys that will be used in the VM
genisoimage -v -J -r -V CONFIG -o ../OSX-KVM/config.iso .
```

* To watch the logs generated by a VM (where the `LOGHOST` variable in `apply.sh` was properly configured), run `nc -dklun 1514 | tr '<' $'\n'` (from a `nix-shell` using the provided `shell.nix`) on the `LOGHOST`.
  * **NOTE**: You'll need to open port 1514 for UDP. To do so temporarily (on NixOS), you may use the following command: `iptables -w -I nixos-fw -p udp --dport 1514 -j nixos-fw-accept`.

* If you run into issues with QEMU and macOS not playing nice, you may need to use a new templated config, `config.plist.qemu.templated`:

<details>
	<summary>config.plist.qemu.templated</summary>

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>ACPI</key>
	<dict>
		<key>DSDT</key>
		<dict>
			<key>Debug</key>
			<false/>
			<key>DropOEM_DSM</key>
			<true/>
			<key>Fixes</key>
			<dict>
				<key>AddDTGP</key>
				<true/>
				<key>AddMCHC</key>
				<false/>
				<key>AddPNLF</key>
				<false/>
				<key>DeleteUnused</key>
				<false/>
				<key>FakeLPC</key>
				<false/>
				<key>FixACST</key>
				<false/>
				<key>FixADP1</key>
				<false/>
				<key>FixDarwin</key>
				<false/>
				<key>FixHDA</key>
				<false/>
				<key>FixHPET</key>
				<false/>
				<key>FixIPIC</key>
				<false/>
				<key>FixLAN</key>
				<false/>
				<key>FixRTC</key>
				<false/>
				<key>FixRegions</key>
				<true/>
				<key>FixS3D</key>
				<false/>
				<key>FixSATA</key>
				<false/>
				<key>FixUSB</key>
				<false/>
			</dict>
			<key>Name</key>
			<string>i440fx-acpi-dsdt.aml</string>
			<key>ReuseFFFF</key>
			<false/>
			<key>Rtc8Allowed</key>
			<false/>
		</dict>
		<key>DisableASPM</key>
		<true/>
		<key>PatchAPIC</key>
		<true/>
		<key>SSDT</key>
		<dict>
			<key>DropOem</key>
			<true/>
			<key>Generate</key>
			<dict>
				<key>APLF</key>
				<false/>
				<key>APSN</key>
				<false/>
				<key>CStates</key>
				<false/>
				<key>PStates</key>
				<false/>
				<key>PluginType</key>
				<false/>
			</dict>
			<key>NoDynamicExtract</key>
			<false/>
			<key>NoOemTableId</key>
			<true/>
			<key>UseSystemIO</key>
			<true/>
		</dict>
	</dict>
	<key>Boot</key>
	<dict>
		<key>Arguments</key>
		<string>@params@</string>
		<string>Apple</string>
		<key>Debug</key>
		<key>DefaultVolume</key>
		<string>system</string>
		<key>HibernationFixup</key>
		<false/>
		<key>Legacy</key>
		<string>PBR</string>
		<key>Log</key>
		<true/>
		<key>Secure</key>
		<false/>
		<key>Timeout</key>
		<integer>@timeout@</integer>
	</dict>
	<key>GUI</key>
	<dict>
		<key>Scan</key>
		<dict>
			<key>Entries</key>
			<true/>
			<key>Tool</key>
			<true/>
		</dict>
		<key>ScreenResolution</key>
		<string>@resolution@</string>
		<key>Theme</key>
		<string>embedded</string>
	</dict>
	<key>Graphics</key>
	<dict>
		<key>Inject</key>
		<dict>
			<key>ATI</key>
			<false/>
			<key>Intel</key>
			<false/>
			<key>NVidia</key>
			<false/>
		</dict>
		<key>NvidiaSingle</key>
		<false/>
	</dict>
	<key>KernelAndKextPatches</key>
	<dict>
		<key>AppleIntelCPUPM</key>
		<true/>
		<key>AppleRTC</key>
		<true/>
		<key>Debug</key>
		<false/>
		<key>KernelCpu</key>
		<true/>
		<key>KernelLapic</key>
		<true/>
		<key>KernelPm</key>
		<true/>
		<key>KernelXCPM</key>
		<false/>
	</dict>
	<key>RtVariables</key>
	<dict>
		<key>BooterConfig</key>
		<string>0x28</string>
		<key>CsrActiveConfig</key>
		<string>@csrFlag@</string>
		<key>ROM</key>
		<data>
		xDCPKu+o
		</data>
	</dict>
	<key>SMBIOS</key>
	<dict>
		<key>BiosReleaseDate</key>
		<string>06/26/2018</string>
		<key>BiosVendor</key>
		<string>Apple Inc.</string>
		<key>BiosVersion</key>
		<string>IM183.88Z.0161.B00.1806260901</string>
		<key>Board-ID</key>
		<string>Mac-BE088AF8C5EB4FA2</string>
		<key>BoardManufacturer</key>
		<string>Apple Inc.</string>
		<key>BoardSerialNumber</key>
		<string>C02736902GUDJWM8C</string>
		<key>BoardType</key>
		<integer>10</integer>
		<key>BoardVersion</key>
		<string>1.0</string>
		<key>ChassisAssetTag</key>
		<string>iMac-Aluminum</string>
		<key>ChassisManufacturer</key>
		<string>Apple Inc.</string>
		<key>ChassisType</key>
		<string>0x09</string>
		<key>Family</key>
		<string>iMac</string>
		<key>FirmwareFeatures</key>
		<string>0xFC0FE137</string>
		<key>FirmwareFeaturesMask</key>
		<string>0xFF1FFF3F</string>
		<key>LocationInChassis</key>
		<string>Part Component</string>
		<key>Manufacturer</key>
		<string>Apple Inc.</string>
		<key>Mobile</key>
		<false/>
		<key>PlatformFeature</key>
		<string>0x00</string>
		<key>ProductName</key>
		<string>iMac18,3</string>
		<key>SerialNumber</key>
		<string>C02VCVICJ1GJ</string>
		<key>Version</key>
		<string>1.0</string>
	</dict>
	<key>SystemParameters</key>
	<dict>
		<key>CustomUUID</key>
		<string>3AF3E5AC-42B1-5FE1-A965-AC7D442AEFA8</string>
		<key>InjectKexts</key>
		<string>Yes</string>
		<key>InjectSystemID</key>
		<true/>
	</dict>
</dict>
</plist>
```

</details>