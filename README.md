# STONKS

STONKS enables publishing updates from a Spotify Playlist to a Slack channel.  It is built for easy deployment to Heroku using Ruby programming language.  For running locally or in non-Heroku environments, please use [Foreman](https://github.com/ddollar/foreman).

STONKS is inspired by the [spotify-playlist-2-slack](https://github.com/petterl/spotify-playlist-2-slack) application by [petterl](https://github.com/petterl).

## Configuration
STONKS requires that specific environment variables be set either in Heroku or using .env files with Foreman.

```
EXECUTION_INTERVAL = An integer representing how often STONKS should poll for changes
SLACK_URL = A full qualified URL to a Slack integration publish webhook
SPOTIFY_CLIENT_ID = A Spotify developer client app ID
SPOTIFY_CLIENT_SECRET = A Spotify developer client app secret
SPOTIFY_USERNAME = The Spotify username of the user who owns the playlist
SPOTIFY_PLAYLIST = The ID of the Spotify playlist
```

## Heroku Dyno Formation

The dyno formation for this application is `worker=1` `web=0`.

## Dependencies

STONKS relies on a few helpful libraries that deserve credit.

* [rspotify](https://github.com/guilhermesad/rspotify) by [guilhermesad](https://github.com/guilhermesad)
* [slack-notifier](https://github.com/stevenosloan/slack-notifier) by [stevenosloan](https://github.com/stevenosloan)

## License
MIT. Copyright &copy; 2015 [Jereme Claussen](https://github.com/jereme)

## Deploy to Heroku
[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

