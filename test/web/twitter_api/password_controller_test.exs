defmodule Pleroma.Web.TwitterAPI.PasswordControllerTest do
  use Pleroma.Web.ConnCase

  alias Pleroma.PasswordResetToken
  alias Pleroma.Web.OAuth.Token
  import Pleroma.Factory

  describe "GET /api/pleroma/password_reset/token" do
    test "it returns error when token invalid", %{conn: conn} do
      response =
        conn
        |> get("/api/pleroma/password_reset/token")
        |> html_response(:ok)

      assert response =~ "<h2>Invalid Token</h2>"
    end

    test "it shows password reset form", %{conn: conn} do
      user = insert(:user)
      {:ok, token} = PasswordResetToken.create_token(user)

      response =
        conn
        |> get("/api/pleroma/password_reset/#{token.token}")
        |> html_response(:ok)

      assert response =~ "<h2>Password Reset for #{user.nickname}</h2>"
    end
  end

  describe "POST /api/pleroma/password_reset" do
    test "it returns HTTP 200", %{conn: conn} do
      user = insert(:user)
      {:ok, token} = PasswordResetToken.create_token(user)
      {:ok, _access_token} = Token.create_token(insert(:oauth_app), user, %{})

      params = %{
        "password" => "test",
        password_confirmation: "test",
        token: token.token
      }

      response =
        conn
        |> assign(:user, user)
        |> post("/api/pleroma/password_reset", %{data: params})
        |> html_response(:ok)

      assert response =~ "<h2>Password changed!</h2>"

      user = refresh_record(user)
      assert Comeonin.Pbkdf2.checkpw("test", user.password_hash)
      assert length(Token.get_user_tokens(user)) == 0
    end
  end
end
