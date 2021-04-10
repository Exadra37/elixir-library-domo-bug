defmodule DomoBugWeb.Router do
  use DomoBugWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DomoBugWeb do
    pipe_through :api

    get "/", ApiController, :index
  end
end
