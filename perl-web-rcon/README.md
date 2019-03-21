# A Rust Web RCON tool written in Perl
This is a Perl client for Rust's "Websocket RCON" interface.  
This was written so I can cron a monthly restart when Facepunch makes us wipe our servers.  

It's intentionally very raw - you shouldn't really be using it for much.

# Installation
Simply put the `rcon` file where you want it.  
You may need to install the perl modules listed under Dependencies.

## Dependencies
This code is written in Perl because I'm lazy. You need Perl to run it.  
This code uses the following Perl modules:
* File::Stat 
* File::Homedir
* IO::Async (IO::Async::Loop ; IO::Async::Stream)
* Net::Async::WebSocket::Client (Net::Async::WebSocket)
* URL::Encode
* JSON

# Configuration & Examples
No configuration is necessary.
You may connect to your server by running rcon with a connection string:
```
./rcon 127.0.0.1:28016/myPassword
```

(Replace `127.0.0.1` with your server's hostname or IP address, `28016`
with your RCON port, and `myPassword` with your RCON password.)

You may set up server aliases in a ~/.rcon file which takes a profile
name and the connection string in the same format as the command line:
```
my_server       127.0.0.1:28016/myPassword
another_server  192.168.1.2:28016/their_password
```
These aliases can be accessed by running `./rcon my_server` or
`./rcon another_server` respectively.



# Compatibility and Testing
It works on Linux. It works on FreeBSD. It works on my Mac.  
I haven't tested it on Windows, it should work but a PowerShell version
would be way cooler.
