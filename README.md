# brat docker

This is a docker container deploying an instance of [brat](http://brat.nlplab.org/).

The `brat-data` volume should be linked to your annotation data, and the `brat-cfg` volume should contain a file called `users.json`.
To add multiple users to the server use `users.json` to list your users and their passwords like so:

```javascript
{
    "user1": "password",
    "user2": "password",
    ...
}
```
