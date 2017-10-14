---
title: Passwordless Authentication in Phoenix
subtitle: Guide for Implementing Magic Login Links
ogImage: phoenix
updated: 2017-01-11
lang: en
tags:
  - Phoenix
  - Authentication
  - Passwordless
  - Magic Links
  - Magic Link
  - Magic Login
  - Token Authentication
  - Tutorial
  - How To
---

There are tons of [different approaches to user authentication](https://www.smashingmagazine.com/2016/06/the-current-state-of-authentication-we-have-a-password-problem/).
Passwordless or *"magic link"* authentication is [very user friendly](https://www.sitepoint.com/passwordless-authentication-works/),
relatively easy to implement and sufficiently secure for most apps.
This article is a step by step guide for implementing passwordless authentication in Phoenix.

<!-- more -->

<div class="note">
  <p><strong>TL;DR</strong>
  This guide assumes you are familiar with
  [the basic flow](https://medium.com/aws-activate-startup-blog/increase-engagement-and-enhance-security-with-passwordless-authentication-212d75d4f7cc#.2gxpaxsuv),
  which you might have experienced in Slack or a growing number of apps:
  You provide an email address and get a *magic link email* containing a one time authentication token.
  The token is valid for a short period of time, clicking the link redeems it and signs you in – no more passwords!</p>
</div>

## The basic user model

This guide assumes you already have a `User` model in place.
If that is not the case: Don't worry and quickly generate it.
For our purpose we just need an `email` property, extend it however you feel like …

```bash
mix phoenix.gen.html User users email:string
```

## The authentication token model

Even though the `AuthToken` is the main subject of this article it is pretty simple:
All it needs is the token value, a timestamp of its creation and the relationship to a user.
As there will be no user interface for anything token related, we can use the model generator to create it.

```bash
mix phoenix.gen.model AuthToken auth_tokens value:string user_id:references:users
```

We need to adjust the migration a little bit, because
- the `updated_at` timestamp is unnecessary
- the `value` should have an unique index

```elixir
def change do
  create table(:auth_tokens) do
    add :value, :string
    add :user_id, references(:users, on_delete: :delete_all)

    timestamps(updated_at: false)
  end

  create index(:auth_tokens, [:user_id])
  create unique_index(:auth_tokens, [:value])
end
```

We also need to reflect these changes in the `AuthToken` model.<br>
While we are at it, let's also adapt the `changeset` function to
- receive the user
- not cast any params
- generate the token value
- ensure uniqueness of the generated value

```elixir
defmodule MyApp.AuthToken do
  use MyApp.Web, :model

  alias MyApp.{Endpoint, User}
  alias Phoenix.Token

  schema "auth_tokens" do
    field :value, :string
    belongs_to :user, User

    timestamps(updated_at: false)
  end

  def changeset(struct, user) do
    struct
    |> cast(%{}, []) # convert the struct without taking any params
    |> put_assoc(:user, user)
    |> put_change(:value, generate_token(user))
    |> validate_required([:value, :user])
    |> unique_constraint(:value)
  end

  # generate a random and url-encoded token of given length
  defp generate_token(nil), do: nil
  defp generate_token(user) do
    Token.sign(Endpoint, "user", user.id)
  end
end
```

This uses `Phoenix.Token` to generate a signed 96 character long string everytime a token is created.
This string is the token value and will be part of the magic link the user receives to sign in.

Having prepared the `AuthToken` model we also need to wire up the other side of the association.
Let's add the `has_many` relation to our `User` schema:

```elixir
schema "users" do
  # add the association among the rest of the schema
  has_many :auth_tokens, AuthToken
end
```

This concludes the model part, let's have a look at the controller.

## Session handling

Our `SessionController` needs four actions to cover the flow:
- `new` presents the login form asking the user for the email address.
- `create` looks up the user by the email, creates the token and sends it.
- `show` is the action to redeem the token and eventually sign in the user.
- `delete` offers the standard logout and drops the current session.

Generate the controller using the HTML-generator and providing the `--no-model` flag:

```bash
mix phoenix.gen.html Session sessions email:string --no-model
```

Add these route definitions for the required actions:

```elixir
get "/signin/:token", SessionController, :show, as: :signin
resources "/sessions", SessionController, only: [:new, :create, :delete]
```

The controller uses a separate `TokenAuthentication` service which we will cover in detail afterwards.
Let's first take a closer look at the implementation of the actions described above:

```elixir
defmodule MyApp.SessionController do
  @moduledoc """
    Actions for creating and signing in with magic link tokens.
  """
  use MyApp.Web, :controller

  alias MyApp.TokenAuthentication

  @doc """
    Login page with email form.
  """
  def new(conn, _params) do
    render(conn, "new.html")
  end

  @doc """
    Generates and sends magic login token if the user can be found.
  """
  def create(conn, %{"session" => %{"email" => email}}) do
    TokenAuthentication.provide_token(email)

    # do not leak information about (non-)existing users.
    # always reply with success message, even though the
    # user might not exist.
    conn
    |> put_flash(:info, "We have sent you a link for signing in via email to #{email}.")
    |> redirect(to: page_path(conn, :index))
  end

  @doc """
    Login user via magic link token.
    Sets the given user as `current_user` and updates the session.
  """
  def show(conn, %{"token" => token}) do
    case TokenAuthentication.verify_token_value(token) do
      {:ok, user} ->
        conn
        |> assign(:current_user, user)
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
        |> put_flash(:info, "You signed in successfully.")
        |> redirect(to: page_path(conn, :index))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "The login token is invalid.")
        |> redirect(to: session_path(conn, :new))
    end
  end

  @doc """
    Ends the current session.
  """
  def delete(conn, _params) do
    conn
    |> assign(:current_user, nil)
    |> configure_session(drop: true)
    |> delete_session(:user_id)
    |> put_flash(:info, "You logged out successfully. Enjoy your day!")
    |> redirect(to: page_path(conn, :index))
  end
end
```

`new` is the only action that needs a template, but there is a little gotcha here:
As we do not have a session model we cannot use the standard way of passing a changeset to the email form.
Instead we have to setup the `form_for` ourselves.
This is what it looks like:

```erb
<h2>Sign In</h2>

<%= form_for @conn, session_path(@conn, :create), [as: :session], fn f -> %>
  <div class="form-group">
    <%= label f, :email, class: "control-label" %>
    <%= text_input f, :email, class: "form-control", autofocus: true %>
    <%= error_tag f, :email %>
  </div>

  <div class="form-group">
    <%= submit "Request login link", class: "btn btn-primary" %>
  </div>
<% end %>
```

## Signing Up

Before we get to the `TokenAuthentication` service we shall not forget about the sign up process.
A nice side effect of using passwordless authentication by providing the login link via email is that we will always have a verified email address.
You can utilize this to attach email verification to the login process for instance.

When the user signs up we should provide the first login token along with the welcome email.
To do so we will use the `TokenAuthentication.provide_token` function that we also used before in the `create` action of the `SessionController`.

```elixir
alias MyApp.{TokenAuthentication, User}

@doc """
  Sign up action, most likely UserController.create/2
"""
def create(conn, %{"user" => user_params}) do
  changeset = User.changeset(%User{}, user_params)

  case Repo.insert(changeset) do
    {:ok, user} ->
      TokenAuthentication.provide_token(user)

      conn
      |> put_flash(:info, "You signed up successfully. Please check your email.")
      |> redirect(to: page_path(conn, :index))

    {:error, changeset} ->
      render(conn, "new.html", changeset: changeset)
  end
end
```

## Putting it all together in the TokenAuthentication module

Now that we have already used the `TokenAuthentication` service extensively, let's look at its implementation in detail.
I stored the module in `web/services` which you need to create as it is a custom folder for stuff like this.
It uses a mailer and `AuthenticationEmail` module which we will get to afterwards.

```elixir
defmodule MyApp.TokenAuthentication do
  @moduledoc """
    Service with functions for creating and signing in with magic link tokens.
  """
  import Ecto.Query, only: [where: 3]

  alias MyApp.{AuthToken, Endpoint, Mailer, Repo, AuthenticationEmail, User}
  alias Phoenix.Token

  # token is valid for 30 minutes / 1800 seconds
  @token_max_age 1_800

  @doc """
    Creates and sends a new magic login token to the user or email.
  """
  def provide_token(nil), do: {:error, :not_found}

  def provide_token(email) when is_binary(email) do
    User
    |> Repo.get_by(email: email)
    |> send_token()
  end

  def provide_token(user = %User{}) do
    send_token(user)
  end

  @doc """
    Checks the given token.
  """
  def verify_token_value(value) do
    AuthToken
    |> where([t], t.value == ^value)
    |> where([t], t.inserted_at > datetime_add(^Ecto.DateTime.utc, ^(@token_max_age * -1), "second"))
    |> Repo.one()
    |> verify_token()
  end

  # Unexpired token could not be found.
  defp verify_token(nil), do: {:error, :invalid}

  # Loads the user and deletes the token as it is now used once.
  defp verify_token(token) do
    token =
      token
      |> Repo.preload(:user)
      |> Repo.delete!

    user_id = token.user.id

    # verify the token matching the user id
    case Token.verify(Endpoint, "user", token.value, max_age: @token_max_age) do
      {:ok, ^user_id} ->
        {:ok, token.user}

      # reason can be :invalid or :expired
      {:error, reason} ->
        {:error, reason}
    end
  end

  # User could not be found by email.
  defp send_token(nil), do: {:error, :not_found}

  # Creates a token and sends it to the user.
  defp send_token(user) do
    user
    |> create_token()
    |> AuthenticationEmail.login_link(user)
    |> Mailer.deliver_now()

    {:ok, user}
  end

  # Creates a new token for the given user and returns the token value.
  defp create_token(user) do
    changeset = AuthToken.changeset(%AuthToken{}, user)
    auth_token = Repo.insert!(changeset)
    auth_token.value
  end
end
```

<div class="note">
**Sidenote:** Almost all of the functions cover edge cases by pattern matching on the arguments.
You will see this pattern oftentimes in Elixir and it makes code much more readable:
Instead of conditionally branching inside a single function you get a separate functions for every case.
I just love this feature! 💜
</div>

The `verify_token_value` function ensures that the token has not expired.
It does so by limiting the fetch from the database and setting a `where` clause for the time period.
You could also handle this by fetching the token without the clause and just using the `Phoenix.Token.verify/4` function providing the `max_age` option.
This would give you the chance to have different error messages for cases of invalid and expired tokens.
(I will leave that as an exercise for you – the `:invalid` and `:expired` cases should get handled in `SessionController.show/2` then)

Once the token is used the `verify_token` function deletes the token.
This way tokens cannot be redeemed multiple times.
This also implies that we might also want a task for cleaning up the database as unused tokens accumulate.
We will save this task for a separate post though – let's get to the mailer …

## Sending the emails

We will use the Bamboo library for creating and sending email in our app.
The [official guide for sending email](http://www.phoenixframework.org/docs/sending-email) uses it too and the
[Bamboo documentation](https://hexdocs.pm/bamboo/readme.html) is great.
It covers a wide range of topics as the library also has proper testing support and Phoenix integration.

I assume you have the Bamboo basics set up and we can focus on the interesting parts.
The `Mailer` module is just for actually sending the emails.
It just contains some wiring and is stored in `lib/my_app/mailer.ex`:

```elixir
defmodule MyApp.Mailer do
  @moduledoc """
    Base mailer. Adds Bamboo mailer for sending mails.
  """
  use Bamboo.Mailer, otp_app: :my_app
end
```

The `AuthenticationEmail` module contains the function that prepares the email.
It gets stored in `web/emails/authentication_email.ex` and this is what it looks like:

```elixir
defmodule MyApp.AuthenticationEmail do
  use Bamboo.Phoenix, view: MyApp.EmailView

  import Bamboo.Email

  @doc """
    The sign in email containing the login link.
  """
  def login_link(token_value, user) do
    new_email()
    |> to(user.email)
    |> from("info@myapp.com")
    |> subject("Your login link")
    |> assign(:token, token_value)
    |> render("login_link.text")
  end
end
```

To keep it short let's focus on what is absolutely necessarry in the login email.
From an UX perspective this could use some more love, but you will get the idea:

```erb
Here is your login link:

<%= signin_url(MyApp.Endpoint, :show, @token) %>

It is valid for 30 minutes.
```

## Summary

Well, that is about it.
You learned the basics of implementing a secure and user-friendly way to authenticate users in your Phoenix app 😀

As this article is already very long I did not include any tests – I might cover this in a separate article some time soon.
We also did not cover edge cases like the user losing access to the email address and recovering from that.
Things like that can get pretty app-specific, nevertheless I hope this guide gives you a basic understanding of how to approach passwordless authentication in Phoenix.

The implementation might also serve as a foundation to add more authentication methods.
By encapsulating the authentication logic into a separate services instead of having it in the controller we can swap it out with a little bit of refactoring.

## Updates

The article got updated thanks to the feedback from [reddit user q1t](https://www.reddit.com/r/elixir/comments/5myy00/comment/dc8gegw)
and [bobbypriambodo in the Elixir Forum](https://elixirforum.com/t/passwordless-authentication-in-phoenix/3212/2).
It now incorporates `Phoenix.Token` to sign and verify the token value.
Also we avoid leaking security information about users that exist in the app.
Thanks very miuch for the nice feedback!
