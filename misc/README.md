# Miscellaneous tools for Rust Linux Servers
These are miscellaneous scripts I use for running my rust server.

# server-runner.sh
This script starts, restarts, and handles wipes of a Rust server.  
It requires `steamcmd` and will use `steamcmd` to check for updates
every time the server restarts.

## Initial Setup
You need to have `steamcmd` and the Rust dedicated server installed.
Follow [Valve's instructions for installing steamcmd](https://developer.valvesoftware.com/wiki/SteamCMD#Linux).
Once steamcmd is installed run it (as the user you want your Rust
servers to run as - ***NOT*** root) and execute the following commands:
```
login anonymous
force_install_dir rust_server
app_update 258550 verify
quit
```

This will automatically update the steamcmd client if necessary and then
install the current version of the Rust dedicated server (Steam App ID
258550).

## Script Installation
If all goes well above your Rust server user should have a directory
named `~/.steam/steamcmd/rust_server` - copy `server_runner.sh` there
(rename it if you want) and configure it by editing the script to set
the "Server Runner Configuration Settings" at the top of the script to
parameters to something sane for your setup.  
The parameters are roughly in order of how likely you are to want to
change them.  

* **IDENTITY**  
  The server identity to use (determines where the save files live)
* **RCON_PASS**  
  The RCON password to use.
  ***YOU REALLY NEED TO SET THIS TO SOMETHING SECURE***
* **SERVER_LEVEL**  
  Procedural Map is what most folks probably want.
* **SERVER_WORLDSIZE**  
  3000 is the default world size.
* **SERVER_SEED** and **SERVER_SALT**  
  Change these to random numbers of your choice.
  Alternatively pick a seed you like from http://playrust.io/gallery/
  and set a random salt value.)
* **SERVER_PORT** and **RCON_PORT**
  The defaults of 28015 and 28016 are the "normal" Rust values.
  Change them if you're running multiple servers and need them
  on different ports.
* **SERVER_IP** and **RCON_IP**  
  The default of 0.0.0.0 ("All configured addresses on this machine")
  is probably what you want.
  DO NOT CHANGE THIS UNLESS YOU KNOW WHY YOU NEED TO.
* **UPDATE**  
  By default the startup script checks Steam for an update every time
  the server restarts. This is probably what you want if you're only
  runing one Rust server on your system.  
  If you are running more than one Rust server on your system set
  UPDATE to "NO" and manually update the application via `steamcmd`
  (using the same command as for installation).
* **RUST_DIR**  
  The default setting is probably what you want here
  (it will be the full path to `~/.steam/steamcmd/rust_server`).  
  If your Rust server directory is somewhere else then change this.

# Your First Startup & server.cfg settings
The first time you run the script it will create a server identity directory
at `~/.steam/steamcmd/rust_server/servers/my_server_identity` (or whatever
you set `IDENTITY` to when you edited the configuration) and initialize
your map.

Once your server is running you can and should create a `server.cfg` file
at `~/.steam/steamcmd/rust_server/servers/my_server_identity/cfg/server.cfg`
to set things like your server name and description, then restart the server
to ensure your changes are loaded. 
A minimal server.cfg file is provided in this repository.

