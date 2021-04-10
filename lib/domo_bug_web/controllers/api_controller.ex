defmodule DomoBugWeb.ApiController do

  use DomoBugWeb, :controller

  def index(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{data: ProgressType.default()})
  end

end
