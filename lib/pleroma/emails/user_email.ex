defmodule Pleroma.UserEmail do
  @moduledoc "User emails"

  import Swoosh.Email

  alias Pleroma.Web.{Endpoint, Router}

  defp instance_config, do: Pleroma.Config.get(:instance)

  defp instance_name, do: instance_config()[:name]

  defp sender do
    {instance_name(), instance_config()[:email]}
  end

  defp recipient(email, nil), do: email
  defp recipient(email, name), do: {name, email}

  def password_reset_email(user, password_reset_token) when is_binary(password_reset_token) do
    password_reset_url =
      Router.Helpers.util_url(
        Endpoint,
        :show_password_reset,
        password_reset_token
      )

    html_body = """
    <h3>Reset your password at #{instance_name()}</h3>
    <p>Someone has requested password change for your account at #{instance_name()}.</p>
    <p>If it was you, visit the following link to proceed: <a href="#{password_reset_url}">reset password</a>.</p>
    <p>If it was someone else, nothing to worry about: your data is secure and your password has not been changed.</p>
    """

    new()
    |> to(recipient(user.email, user.name))
    |> from(sender())
    |> subject("Password reset")
    |> html_body(html_body)
  end
end