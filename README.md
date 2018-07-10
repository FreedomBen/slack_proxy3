# SlackProxy

## Developing

Start up postgres.  There's a script to make it easy for you, but you can use whatever you want if you prefer something else.  Just update the username/password in `config/dev.exs`)

```sh
./scripts/start-postgres.sh
```

If you would like a `psql` prompt on that database, use the script:

```sh
./scripts/psql.sh
```

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix


## Resources

Pages are server-side rendered using eex (embedded elixir).  Sessions are stored in cookies browser side.  Only admins can change things and create users.  Non admins can view things.

### Users

```
name:
username:
is_admin: only admins can change things, and add new users
```

### Credentials

```
email:
password: (Virtual, doesn't get saved.  gets hashed and savedi n password_hash)
user_id: to tie to the user
```

### Sessions

No db table.  These live in cookies inside the browser.

### Build Proxies

```
avatar: Avatar to post to slack with
channel: Channel to post to
username: username to post with
service_base_url: used for generating links to the merge request
```
