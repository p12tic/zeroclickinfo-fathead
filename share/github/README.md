### GitHub Fathead

Requires these CPAN modules:

* LWP::UserAgent
* JSON::XS
* Data::Dumper

Requires you to set up a GitHub OAuth application so you can make 5000 requests / hour instead of 60. Create the application [here](https://github.com/settings/applications/new) then set these two environment variables in your shell:

* GITHUB\_FATHEAD\_CLIENT\_ID
* GITHUB\_FATHEAD\_CLIENT\_SECRET

`fetch.sh` downloads the list of *All repos on GitHub*. This is not a fast process. I recommend running it in a detached screen session so you can check on it.
